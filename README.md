# Termux Setup

Hyperling's scripts for a productive Termux environment.

# Install / How To Use

1. Download the repository.

    ```sh
    git clone https://github.com/Hyperling/Termux termux
    ```

1. Dive into the directory.

    ```sh
    cd termux
    ```

1. Ensure all files can be executed.

    ```sh
    chmod 755 *.sh
    ```

1. Make any modifications to the env.example file.
    - Only if you do not already have ~/.env already.

1. Run the deployment script.

    ```sh
    ./setup.sh
    ```

1. All done!

# Updates

Each program is developed to be run numerous times, so all that needs done is following the Install instructions again.

A shortcut for this exists after the initial install, `termux-reload`.

# Development

Since the project self-destructs, it is recommended to copy the folder for each run, then execute the copied files.

```sh
cp -r ../termux ~/termux-copy
cd ~/termux-copy
chmod 755 *.sh
./setup.sh
```

Or use the `test-termux` command if the project is already loaded..
