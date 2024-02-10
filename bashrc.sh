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

# Easily get to storage devices.
export SS="~/storage/shared/"
alias ss="cd $SS"
alias sd="ss"
alias storage="ss"
alias home="ss"

# Shortcut to media.
export DCIM="$SS/DCIM/Camera"
alias dcim="cd $DCIM"

# Shortcut to Code
export DCIM="$SS/Code"
alias dcim="cd $CODE"

# Help prevent mistakes.
alias cp="cp -v"
alias mv="mv -v"
alias rm="echo 'Move to ~/storage/shared/TRASH/ instead!'"

## Functions ##

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

cd ~/storage/shared/

echo "'$0' completed!"