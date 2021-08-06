export profile="cloud-lab"
rm -f ~/.ssh/${profile}_id_rsa* ;
echo >&2 "*** generating a new set of ssh keys for '$profile' on host" ;
[ ! -r ~/.ssh/id_rsa ] && ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N "" ;
ssh-keygen -b 4096 -t rsa -f ~/.ssh/${profile}_id_rsa -q -N "" ;
