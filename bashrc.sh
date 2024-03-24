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
alias reload-bash="source ~/.bashrc"
alias bash-reload="reload-bash"
alias reload="reload-bash"

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

# Quickies
alias update="pkg update && pkg upgrade"
alias bye="exit"
alias goodbye="update -y && bye"
alias install="pkg install"

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
	passes="$6"

	# Validations
	if [[ -z $file || ! -e $file ]]; then
		echo "ERROR: Original file '$file' does not exist." >&2
		process-video-usage
		return 1
	fi

	if [[ -z $newfile ]]; then
		echo "ERROR: New file's name must be provided." >&2
		process-video-usage
		return 1
	elif [[ -e $newfile ]]; then
		echo "ERROR: New file '$newfile' already exists." >&2
		du -h "$newfile"
		process-video-usage
		return 1
	fi
	
	echo "`date` - Converting '$file' to '$newfile'."

	if [[ -z $video ]]; then
		video="2000k"
	fi
	video="-maxrate $video"

	if [[ -z $audio ]]; then
		audio="192k"
	fi
	audio="-b:a $audio"

	if [[ -z $size ]]; then
		size="720"
	fi
	size="-filter:v scale=-1:$size"
	
	if [[ -z $passes ]]; then
		passes=1
	fi
	pass=""
	if [[ $passes != 1 ]]; then
		passes=2
		pass="-pass 2"
	fi

	## Main ##
	# More information on two-pass processing with ffmpeg
	# https://cinelerra-gg.org/download/CinelerraGG_Manual/Two_pass_Encoding_with_FFmp.html
	if [[ $passes == 2 ]]; then
		set -x
		ffmpeg -nostdin -hide_banner -loglevel quiet \
			-i "$file" $size $video $audio \
			-filter:a "dynaudnorm=f=33:g=65:p=0.66:m=33.3" \
			-vcodec libx264 -movflags +faststart \
			-pass 1 -f mp4 /dev/null -y
		status=$?
		set +x
		echo "`date` - Done with the first pass."
		if [[ $status != 0 ]]; then
			echo "Received unsuccessful status, exiting."
			return 1
		fi
	fi
	
	set -x &&
	ffmpeg -nostdin -hide_banner -loglevel quiet \
		-i "$file" $size $video $audio \
		-filter:a "dynaudnorm=f=33:g=65:p=0.66:m=33.3" \
		-vcodec libx264 -movflags +faststart \
		$pass "$newfile"
	status="$?"
	set +x
	echo "`date` - Done with the final pass."
	
	if [[ $passes == 2 && $status == 0 ]]; then
		mv -v ffmpeg2pass*.log* ~/TRASH/
	fi

	sync
	sleep 10
	sync
	if [[ -s $newfile ]]; then
		echo "`date` - Getting file sizes."
		du -h "$file"
		du -h "$newfile"
	else
		echo "ERROR: New file not created or has a 0 size." >&2
	fi

	echo -e "\n`date` - Finished with status '$status'."
	return $status
}
alias pv="process-video"

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

# Allow converting video to audio ad other smaller
# tasks than what process-video is intended to do.
function basic-process-usage {
	echo "basic-process INPUT OUTPUT NORMALIZE [EXTRA]"
	echo -n "Pass a file through ffmpeg with the option"
	echo "to easily normalize the audio with a Y."
	echo "Examples:"
	echo "- Normalize audio on a video."
	echo "    basic-process video.mp4 normalized.mp4 Y"
	echo "- Convert a video to audio at 192k."
	echo "    basic-process video.mp4 audio.mp3 N '-b:a 192k'"
}
function basic-process {
	# Parameters
	input="$1"
	output="$2"
	typeset -u normalize
	normalize="$3"
	extra="$4"

	echo "`date` - Starting basic-process"

	# Validations
	if [[ -z $input || ! -e $input ]]; then
		echo "ERROR: Input file '$input' does not exist." >&2
		basic-process-usage
		return 1
	fi

	if [[ -z $output ]]; then
		echo "ERROR: Output file's name must be provided." >&2
		basic-process-usage
		return 1
	elif [[ -e $output ]]; then
		echo "ERROR: Output file '$output' already exists." >&2
		du -h "$output"
		basic-process-usage
		return 1
	fi

	if [[ $normalize == "Y" ]]; then
		echo "Normalize set to TRUE."
		normal="-filter:a dynaudnorm=f=33:g=65:p=0.66:m=33.3"
	else
		echo "No audio normalization is being done."
	fi

	# Main
	echo "`date` - Converting '$input' to '$output'."
	set -x
	ffmpeg -nostdin -hide_banner -loglevel quiet \
		-i "$input" $extra $normal "$output"
	status=$?
	set +x

	if [[ $status != 0 ]]; then
		echo "`date` - WARNING: ffmpeg exited with status '$status'." >&2
	fi

	# Finish
	if [[ ! -s $output ]]; then
		echo "`date` - ERROR: Output '$output' not created or has 0 size." >&2
		return 1
	fi

	sync
	echo "`date` - '$output' has been created successfully."
	sleep 3
	du -h "$input"
	du -h "$output"

	echo "`date` - Finished basic-process"
	return 0
}
alias v2a="basic-process"
alias vta="v2a"
alias va="v2a"
alias pa="v2a"
alias fix-audio="basic-process"

# Go to normal storage. DISABLED, use shortcut aliases instead.
#cd ~/storage/shared/

PROG="$(basename -- "${BASH_SOURCE[0]}")"
echo "'$PROG' completed!"
