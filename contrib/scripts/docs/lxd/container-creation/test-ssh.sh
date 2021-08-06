export container_name="cloud-lab"
export LC_ALL=C ;
ssh ${container_name} 2>/dev/null -- echo '***** $(whoami)@$(hostname) is ready *****'
