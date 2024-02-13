# 2024-02-10 Hyperling

if [[ -e ~/.env ]]; then
	source ~/.env
fi

## Aliases ##

# Quickly log onto production server.
# Setting up ssh-keygen and ssh-copy-id make this even faster!
if [[ -n $PROD_PORT && -n $PROD_USER && -n $PROD_NAME ]]; then
	alias prod="ssh -p $PROD_PORT $PROD_USER@$PROD_NAME"
else
	alias prod="echo 'ERROR: .env not set up properly, please fix and reload RC.'"
fi

# Quickies
alias reload="source ~/.bashrc"

# Easily get to storage devices.
export SS="~/storage/shared"
alias ss="cd $SS"
alias sd="ss"
alias storage="ss"
alias home="ss"

# Shortcut to media.
export DCIM="$SS/DCIM/Camera"
alias dcim="cd $DCIM"

# Shortcut to Code
export CODE="$SS/Code"
alias code="cd $CODE"

# Shortcuts for TRASH.
export TRASH="$SS/TRASH"
alias trash="cd $TRASH"
alias clean-trash="bash -c 'rm -rfv $TRASH/*'"
alias trash-clean="clean-trash"
alias check-trash="du -h $TRASH"
alias trash-check="check-trash"

# Help prevent mistakes.
alias cp="cp -v"
alias mv="mv -v"
alias rm="echo 'Move to ~/storage/shared/TRASH/ instead!'"

## Functions ##

# Optimize the bitrate and audio levels for an edited video.
function process-video-usage {
   echo "USAGE: process-video oldFile newFile [videoBitrate] [audioBitrate] [sizeRating]"
	echo -n "Purpose: Call ffmpeg with preferred video posting settings. " 
	echo -n "Bitrates default to 2000k and 192k, size is 720. "
	echo "These work well on Odysee and are fairly small as backups."
	echo "Examples:"
	echo "- Create a small file for quick streaming." 
	echo "    process-video youcut.mp4 20240210.mp4 1200k 128k 480"
	echo "- Create a larger file for something like YouTube."
	echo "    process-video youcut.mp4 20240210_1080p.mp4 5000k 256k 1080"
}
function process-video {
   # Parameters
   file="$1"
   newfile="$2"
   video="$3"
   audio="$4"
	size="$5"
   
   # Validations
   if [[ -z $file || ! -e $file ]]; then
      echo "ERROR: Original file '$file' does not exist." >&2
      process-video-usage
		return 1
   fi
   
   if [[ -z $newfile || -e $newfile ]]; then
      echo "ERROR: New file '$newfile' already exists." >&2
      process-video-usage
   elif [[ -e $newfile ]]; then
      echo "ERROR: New file '$newfile' already exists." >&2
		process-video-usage
		return 1
   fi

   if [[ -z $video ]]; then
      video="2000k"
   fi
   video="-b:v $video"

   if [[ -z $audio ]]; then
      audio="192k"
   fi
   audio="-b:a $audio"

	if [[ -z $size ]]; then
		size="720"
	fi
	size="-filter:v scale=-1:$size"

	echo "`date` - Converting '$file' to '$newfile'."
   
   # Main
   set -x
   ffmpeg -nostdin -hide_banner -loglevel quiet \
      -i "$file" -filter:a "dynaudnorm=f=33:g=65:p=0.66:m=33.3" \
	  -vcodec libx264 -movflags +faststart $size $video $audio \
      "$newfile"
	status="$?"
    set +x

 if [[ -e $newfile ]]; then
   du -h "$file"
	 du -h "$newfile"
	else
    echo "ERROR: New file not created." >&2
 fi

	echo -e "\n`date` - Finished with status '$status'."
	return $status
}

# Quickly commit code to a repo.
function commit {
	message="$1"
	if [[ -z $message ]]; then
		echo "ERROR: A message is required." >&2
		echo 'USAGE: commit "My commit message."' >&2
		return 1
	fi
	git add . && git commit -m "$message" && git push
}

# Easily test this project after committing changes.
# Otherwise can just source this file unless testing setup.sh.
function test-termux {
	sh -c "rm -rf ~/termux-deleteme ~/TRASH/termux-deleteme" 2>/dev/null
	git clone https://github.com/Hyperling/Termux ~/termux-deleteme --branch=dev
	chmod 755 ~/termux-deleteme/*.sh
	~/termux-deleteme/setup.sh
}
alias reload-termux="test-termux"
alias termux-test="test-termux"
alias termux-reload="reload-termux"

# Go to normal storage. DISABLED, use shortcut aliases instead.
#cd ~/storage/shared/

PROG="$(basename -- "${BASH_SOURCE[0]}")"
echo "'$PROG' completed!"
