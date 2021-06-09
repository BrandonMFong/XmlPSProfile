# @file setup.sh
# @author Brando 
# @date 2021-1-25
#

## Variables Start ## 
arg1=$1;                                        # Type of unix shell
bashFlag="-bash";                               # Bash shell
zshFlag="-zsh";                                 # zsh shell
helpFlag="-help";                               # help flag
okayToContinue=true;                            # okay to continue flag 
xProDirectory="$HOME/.xPro"                     # xPro directory path
binDirectory="$xProDirectory/bin";              # bin directory 
out="$xProDirectory/profile.xml";               # Profile
gitRepoDir=$(pwd);                              # get the xPro directory 
configPath="${gitRepoDir}/Config/Users";
configFile="/${configFile}.xml";                # config name 
baseConfig="/Makito.xml";                       # TODO read from app.json 
helpFlag="-help";
usage="usage: $0 [ -bash | -zsh ]";
footer="See '$0 ${helpFlag}' for an overview."
selectitem="./bin/xpro.selectitem"
enumdir="./bin/xpro.enumdir"
profileScript="./Profile.sh"
## Variables End ## 

help () 
{
    showHelp=$1
    printf "${usage}\n";
    if [ $showHelp = true ]
    then 
        printf "\nArguments for profile setup: "
        printf "\n\t-bash\tUse if you want to set up bash profile";
        printf "\n\t-zsh\tUse if you want to set up z shell profile";
        printf "\n";
    fi 
    printf "\n${footer}\n";
}

pushd "$(dirname "$0")" > /dev/null;

# Handle arguments
if [[ ${arg1} == ${zshFlag} ]]
then 
    shellProfile="$HOME/.zshrc";
    okayToContinue=true;
elif [[ ${arg1} == ${bashFlag} ]]
then 
    shellProfile="$HOME/.bashrc";
    okayToContinue=true;
elif [[ ${arg1} == ${helpFlag} ]]
then 
    help true;
    okayToContinue=false;
else 
    help false;
    okayToContinue=false;
fi 

# Make and copy files 
if [ $okayToContinue = true ]
then 
    if [ -d $xProDirectory ]
    then 
        rm -r $xProDirectory;
    fi
    
    mkdir $xProDirectory;               # Create xPro directory 
    mkdir $binDirectory;                # Create bin directory 
    cp -f $profileScript $shellProfile; # create the profile script 

    # See if app pointer exists 
    if [ -f $out ]
    then 
        rm $out;
    fi 
    
    touch $out; # Create app pointer 
fi

# Asking if user wants to use or create
# going to use Makito.xml as basis 
# Have user choose if they want to create or use an existing config
if [ $okayToContinue = true ]
then 
    printf "What do you want to do?\nCreate New Config[1]\nUse Existing Config[2]\nSo: ";
    read choice; # TODO read from app.json
fi 

if ( [ $okayToContinue = true ] ) && ( [[ -z $choice ]] )
then 
    printf "$0: No arguments passed";
    help false
    okayToContinue=false;
elif ( [ $okayToContinue = true ] ) && ( [[ $choice -ne 1 ]] ) && ( [[ $choice -ne 2 ]] )
then 
    printf "$0: Not choice 1 or 2\n";
    help false
    okayToContinue=false;
fi 

if [ $okayToContinue = true ]
then
    # create new config 
    if [ $choice -eq 1 ]
    then 
        # create config file name
        read -p "Config File Name: " configFile;
        configFile="/${configFile}.xml"; # config name 
        
        # Copy base config to new config 
        cp -f "${configPath}${baseConfig}" "${configPath}${configFile}";
        okayToContinue=true;

    # Use existing config
    elif [ $choice -eq 2 ] 
    then
        printf "Choose out of the following:\n"
        $enumdir $configPath
        read -p "So: " choice;
        choice=$(($choice - 1));
        configFile="/$($selectitem -path $configPath -index $choice)";
        printf $configFile;
        okayToContinue=true;
    else 
        okayToContinue=false;
    fi 

fi 

# Keeping it in this if statement because I don't want to execute it if the user input something wrong 
# Write to apppointer and copy binaries
if [ $okayToContinue = true ]
then
    # app pointer
    echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>" | tee -a $out;
    echo "<Machine MachineName=\"KAMANTA\">" | tee -a $out;
    echo "  <GitRepoDir>${gitRepoDir}</GitRepoDir>" | tee -a $out;
    echo "  <ConfigFile>${configFile}</ConfigFile>" | tee -a $out;
    echo "</Machine>" | tee -a $out;

    # Binaries
    cp -r "./bin/" $xProDirectory;
fi
popd  > /dev/null;
