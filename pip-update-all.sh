#!/usr/bin/env bash

# -------- NOTES --------
# You can symlink with:
# sudo ln -s ./pip-update-all.sh /usr/local/bin/pip-update-all

# -------- CONSTANTS -------
ver='0.2'

# -------- HELPER FUNCTIONS --------
# Handle arguments
for i in "$@"
do
case $i in
    -y)
    yestoall=true
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done

# Promt function
promptyn () {
    if [ "$yestoall" = true ] ; then
        return 0
    fi

    while true; do
        read -p "$1 " yn
        case $yn in
            [Yy]* ) return 0;;  # Y ...or more* :)
            '' ) return 0;;  # [ENTER] means 'yes'
            [Nn]* ) return 1;;
            * ) echo 'Please answer yes [Yy]* or no [Nn]* .';;
        esac
    done
}

#    EXAMPLE usage:
# if promptyn "is the sky blue?"; then
#     echo "yes"
# else
#     echo "no"
#     exit 1
# fi

# -------- LOGO ------------
echo '         _        __  __        __     __         ___   __   __  '
echo '   ___  (_)__    / / / /__  ___/ /__ _/ /____    / _ | / /  / /  '
echo '  / _ \/ / _ \  / /_/ / _ \/ _  / _ `/ __/ -_)  / __ |/ /__/ /__ '
echo ' / .__/_/ .__/  \____/ .__/\_,_/\_,_/\__/\__/  /_/ |_/____/____/ '
echo "/_/    /_/          /_/                                   v $ver "

# -------- PIP -------------------------------------------------------
# update pip2 (explicitly) outdated packages
if promptyn 'Update pip + all pip2 packages? ([y]/n)'; then
    # update pip itself first:
    echo '>>> updating pip ...'
    pip install --upgrade pip
    # then packages:
    echo '>>> updating pip2 packages ...'
    lst=$(pip2 list --outdated | awk '{ print $1 }')  # these are ONLY the outdated packages.
    if [ ! -z "$lst" ]; then  # not null
        pip2 install $lst --upgrade
        echo '>>> ... Done.'
    else
        echo '>>> ... nothing is outdated.'
    fi
fi

# update pip3 (explicitly) outdated packages
if promptyn 'Update pip3 + all pip3 packages? ([y]/n)'; then
    # update pip3 itself first:
    echo '>>> updating pip3 ...'
    pip3 install --upgrade pip
    # then packages:
    echo '>>> updating pip3 packages ...'
    lst=$(pip3 list --outdated | awk '{ print $1 }')  # these are ONLY the outdated packages.
    if [ ! -z "$lst" ]; then  # not null
        pip3 install -U $lst
        echo '>>> ... Done.'
    else
        echo '>>> ... nothing is outdated.'
    fi
fi

# no need to pip clean (cache), if > pip 6.0

# -------- CONDA -------------------------------------------------------
# update all conda packages
if promptyn 'Update all conda packages? ([y]/n)'; then
    # conda update --all  # No longer works because "conda" is now a bash function; Need to do:
    # shellcheck disable=SC1090  # for the below command; because I used "~" instead of the full path.
    source ~/anaconda/anaconda/etc/profile.d/conda.sh; conda update --all
    #                     within this script ^         ^ call this function   ^ with these parameters
    #                  Inside this script, in the conda() function, rest of *) params are handled by the conda executable.
    #     see:  https://superuser.com/questions/106272/how-to-call-bash-functions
fi

# conda clean
if promptyn 'conda clean? ([y]/n)'; then
    # conda clean --all  # No longer works.
    # shellcheck disable=SC1090
    source ~/anaconda/anaconda/etc/profile.d/conda.sh; conda clean --all
fi

# --------- BREW -------------------------------------------------------
if promptyn 'brew update & upgrade (all)? ([y]/n)'; then
    # brew upgrade ONLY if brew update sucessfull.
    brew update && brew upgrade
fi

if promptyn 'brew cleanup? ([y]/n)'; then
    brew cleanup
fi
