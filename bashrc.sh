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
   echo "USAGE: process-video oldFile newFile [videoBitrate] [audioBitrate]"
	echo "Call ffmpeg with preferred video posting settings." 
}
function process-video {
   # Parameters
   file="$1"
   newfile="$2"
   video="$3"
   audio="$4"
   
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
      video="-b:v 2000k"
   else
      video="-b:v $video"
   fi

   if [[ -z $audio ]]; then
      audio="-b:a 192k"
   else
      audio="-b:a $audio"
   fi

	echo "`date` - Converting '$file' to '$newfile' using '$video $audio'"
   
   # Main
   ffmpeg -nostdin -hide_banner -loglevel quiet \
		-vcodec libx264 $video $audio -movflags +faststart \
		-af "dynaudnorm=f=33:g=65:p=0.66:m=33." \
		-i "$file" "$newfile"
	status="$?"

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

# WORK IN PROGRESS
# Easily test this project.
function test-termux {
	# TBD I have no idea why this does not work with the $CODE variable.
	cd ~
	ls storage/shared/Code/termux-dev/
	ls $CODE
	copy="~/termux-copy"
	[[ -e $copy && $copy != "/" ]] && rm -rfv "$copy"
	cp -r "$CODE"/termux* "$copy"
	chmod 755 "$copy"/*.sh
	"$copy"/setup.sh
} # WORK IN PROGRESS

cd ~/storage/shared/

echo "'$0' completed!"