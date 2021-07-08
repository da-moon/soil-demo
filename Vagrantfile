# -*- mode: ruby -*-
# vi: set ft=ruby :

synced_folder  = ENV[     'SYNCED_FOLDER'      ]  || "/home/vagrant/#{File.basename(Dir.pwd)}"
memory         = ENV[           'MEMORY'       ]  || 8192
cpus           = ENV[           'CPUS'         ]  || 8
vm_name        = ENV[           'VM_NAME'      ]  || File.basename(Dir.pwd)
forwarded_ports= []
provisioners   = [
  "node",
  "python",
  "ansible",
  "ripgrep",
  "docker",
  "lxd",
  "starship",
  "rust-core-utils",
  "rust-toolchain",
  "kube-util",
  "spacevim",
]
utility_scripts= [
 "disable-ssh-password-login",
 "lxd-debian",
]
$cleanup_script = <<-SCRIPT
apt-get autoremove -yqq --purge > /dev/null 2>&1
apt-get autoclean -yqq > /dev/null 2>&1
apt-get clean -qq > /dev/null 2>&1
rm -rf /var/lib/apt/lists/*
SCRIPT
INSTALLER_SCRIPTS_BASE      = "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer"
UTIL_SCRIPTS_BASE           = "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/util"
Vagrant.configure("2") do |config|
  config.vm.define "#{vm_name}"
  config.vm.hostname = "#{vm_name}"
  config.vm.synced_folder ".","#{synced_folder}",auto_correct:true, owner: "vagrant",group: "vagrant",disabled:true
  config.vm.provider "virtualbox" do |vb, override|
    override.vm.box="generic/debian10"
    vb.memory = "#{memory}"
    vb.cpus   = "#{cpus}"
    # => enable nested virtualization
    vb.customize ["modifyvm",:id,"--nested-hw-virt", "on"]
    override.vm.synced_folder ".", "#{synced_folder}",disabled: false,
      auto_correct:true, owner: "vagrant",group: "vagrant",type: "virtualbox"
  end if Vagrant.has_plugin?('vagrant-vbguest')
  config.vm.provider "hyperv" do |h,override|
    override.vm.box="generic/debian10"
    h.enable_virtualization_extensions = true
    h.linked_clone = true
    h.cpus   = "#{cpus}"
    h.memory = "#{memory}"
    h.maxmemory = "#{memory}"
    override.vm.network "public_network"
    override.vm.synced_folder ".", "#{synced_folder}",disabled: false,auto_correct:true, type: "smb",
    owner: "vagrant",group: "vagrant"
  end
  config.vm.provider "libvirt" do |libvirt,override|
    override.vm.box="generic/debian10"
    libvirt.memory = "#{memory}"
    libvirt.cpus = "#{cpus}"
    libvirt.nested = true
    libvirt.cpu_mode = "host-passthrough"
    libvirt.driver = "kvm"
    override.vm.synced_folder ".", "#{synced_folder}",
      disabled: false,auto_correct:true, owner: "1000", group: "1000",
      type: "9p",accessmode: "passthrough"
    override.vm.provision "shell",
      privileged:true,
      name:"p9-kernel-support",
      inline: <<-SCRIPT
      [ ! -L /usr/local/bin/modprobe ] && sudo ln -s /sbin/modprobe /usr/local/bin/modprobe
      SCRIPT
  end if Vagrant.has_plugin?('vagrant-libvirt')
  # [ NOTE ] => vagrant 2.2.16 has a bug in which makes it impossible to provision
  # google boxes with ssh , either use version >=2.2.17 or version <=2.2.16 
  config.vm.provider "google" do |google,override|
    username                          = ENV['USERNAME'] || %x[whoami].chomp()
    google_project_id                 = ENV['GOOGLE_PROJECT_ID'] || %x[gcloud config get-value core/project].chomp()
    gcloud_iam_account                = "#{vm_name}@#{google_project_id}.iam.gserviceaccount.com"
    ssh_pub_key                       = File.expand_path("~/.ssh/#{vm_name}.pub")).chomp()
    google.name                       = "#{vm_name}"
    google.disk_type                  = "pd-ssd"
    google.disk_size                  = ENV["GCLOUD_DISK_SIZE"] || "50"
    google.google_json_key_location   = ENV["GOOGLE_APPLICATION_CREDENTIALS"] 
    google.google_project_id          = google_project_id
    google.zone                       = ENV["CLOUDSDK_COMPUTE_ZONE"] || %x[gcloud config \
                                        get-value compute/zone].chomp()
    google.machine_type               = ENV["GCLOUD_MACHINE_TYPE"] || "n1-standard-8"
    google.image                      = ENV["GCLOUD_IMAGE"] || %x[gcloud compute images \
                                        list --format='value(NAME)' \
                                        --filter='name ~ debian AND family ~ debian-10'
                                        ].chomp()
    google.image_project_id           = ENV["GCLOUD_IMAGE_PROJECT_ID"] || %x[gcloud compute \
                                        images list --format='value(PROJECT)' \
                                        --filter='name ~ debian AND family ~ debian-10'
                                        ].chomp()
                                        
    google.metadata                   = {'ssh-keys' => "#{username}:#{File.read(ssh_pub_key).chomp()}"}
    override.vm.box                   = "google/gce"
    override.ssh.username             = username
    override.ssh.private_key_path     = File.expand_path("~/.ssh/#{vm_name}")
    override.ssh.extra_args           = [
      "-vvv",
    ]
    # google.trigger.before :up do |trigger|
    #   trigger.info = "generating ssh key"
    #   trigger.ruby do |env,machine|
    #     path = File.expand_path("~/.ssh/#{vm_name}")).chomp()}
    #     File.delete(path) if File.exist?(path)
    #     File.delete("#{path}.pub") if File.exist?("#{path}.pub")
    #     %x{ssh-keygen -q -N "" -t rsa -b 2048 -f "#{path}"}
    #   end
    # end
    # google.trigger.before :up do |trigger|
    #   trigger.info = "setting up IAM service account and Google Application Credentials"
    #   trigger.ruby do |env,machine|
    #   end
    # end

    override.vm.synced_folder ".", "/workspace", type: 'rsync',
      rsync__args: ["--verbose", "--archive", "-z"],
      owner: ENV['USERNAME'] || %x[whoami].chomp(),
      group: ENV['USERNAME'] || %x[whoami].chomp(),
      sync__exclude: [
        '.git',
        '.vagrant',
      ]
  end if Vagrant.has_plugin?('vagrant-google')
  forwarded_ports.each do |port|
    config.vm.network "forwarded_port",
      guest: port,
      host: port,
      auto_correct: true
  end
  config.vm.provision "shell",privileged:true,name:"cleanup", inline: $cleanup_script
  config.vm.provision "shell",
    privileged:false,
    name:"init",
    path: "#{INSTALLER_SCRIPTS_BASE}/init"
  # [ NOTE ] => downloading helper executable scripts
  utility_scripts.each do |utility|
    config.vm.provision "shell",
      privileged:false,
      name:"#{utility}-utility-script",
      inline: <<-SCRIPT
    [ -r /usr/local/bin/#{utility} ] || \
      sudo curl -s \
      -o /usr/local/bin/#{utility} \
      #{UTIL_SCRIPTS_BASE}/#{utility} && \
      sudo chmod +x /usr/local/bin/#{utility}
    SCRIPT
  end
  # [ NOTE ] => provisioning
  provisioners.each do |provisioner|
    config.vm.provision "shell",
      privileged:false,
      name:"#{provisioner}",
      path: "#{INSTALLER_SCRIPTS_BASE}/#{provisioner}"
  end
  config.vm.provision "shell",
    privileged:false,
    name:"hashicorp",
    path:"#{INSTALLER_SCRIPTS_BASE}/hashicorp",
    args:[
      "--skip", "otto",
      "--skip", "serf",
      "--skip", "boundary",
      "--skip", "waypoint",
    ]
  config.vm.provision "shell",
      privileged:false,
      name:"extra-tools",
      inline: <<-SCRIPT
			set -xeu
      wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - ;
      echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/chrome.list > /dev/null
      sudo apt-get install -y upx cmake libssl-dev fzf libgconf-2-4 google-chrome-stable ;
      for i in {1..5}; do wget -O \
        /tmp/vsls-reqs \
        https://aka.ms/vsls-linux-prereq-script && break || sleep 15; done ;
      sudo bash /tmp/vsls-reqs ;
      rm -f /tmp/vsls-req ;
      sudo snap install diagon ;
      sudo python3 -m pip install asciinema yq pre-commit
      sudo yarn global add --silent --prefix /usr/local \
        @commitlint/cli \
        @commitlint/config-conventional \
        remark \
        remark-cli \
        remark-stringify \
        remark-frontmatter \
        wcwidth \
        prettier \
        bash-language-server \
        dockerfile-language-server-nodejs \
        puppeteer \
        reveal-md ;
      rustup default stable
      cargo install -j`nproc` convco ;
    SCRIPT
  config.trigger.after [:provision] do |t|
    t.info = "cleaning up after provisioning"
    t.run_remote = {inline: $cleanup_script }
  end
end
