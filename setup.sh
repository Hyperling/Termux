# No Shebang For Termux
# 2024-02-10 Hyperling

echo "`date` - Starting Hyperling's Termux Setup"

DIR="`dirname $0`"
cd $DIR
DIR="`pwd`"

echo -e "\n`date` - Upgrade Package Repos"
pkg update &&
   pkg upgrade

echo -e "\n`date` - Check Storage Permission"
if [[ ! -e ~/storage/shared ]]; then
   sleep 3
   termux-setup-storage
   if [[ -e ~/storage/shared/ ]]; then
      echo "~/storage/shared/ now exists. :)"
	else
      echo "ERROR: Something ain't right, Jim! Abort!" >&2
		exit 1
	fi
else
   echo "Everything looks good already, pal."
fi

echo -e "\n`date` - Install Software"
pkg install \
   openssh tsu vim htop git cronie \
   nmap traceroute \
   ffmpeg

echo -e "\n`date` - BASH Environment"
if [[ ! -e ~/.env ]]; then
	if [[ -e env.example ]]; then
	   mv -v env.example ~/.env
	else
 	  echo "ERROR: Neither .env or env.example found." >&2
	fi
else
	echo "'.env' already exists. Good job!"
	rm -v env.example
fi

if [[ -e bashrc.sh ]]; then
	mv -v bashrc.sh ~/.bashrc
else
   echo "ERROR: bashrc.sh not found, skipping." >&2
fi

echo -e "\n`date` - Cleanup"
if [[ -d ~/TRASH ]]; then
	rm -rfv ~/TRASH
fi
if [[ ! -e ~/storage/shared/TRASH ]]; then
	mkdir -pv ~/storage/shared/TRASH
fi
ln -s ~/storage/shared/TRASH ~/TRASH

cd ..
if [[ -n $DIR && $DIR != "/" ]]; then
	mv -v $DIR ~/TRASH/termux-"`date +'%Y%m%d%H%M%S'`" | 
		grep -v '/.git/'
fi

echo -e "\n*******"
echo "Don't forget to reload your environment!"
echo "  source .bashrc"
echo "*******"

echo -e "\n`date` - Finished Hyperling's Termux Setup"
exit 0
