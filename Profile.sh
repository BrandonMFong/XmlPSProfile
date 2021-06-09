# z shell profile
# xml parsing: sudo apt-get install libxml2-utils
# sudo apt install apt
# Known issues: if object count is one, that object will not load 

dirPath="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
xProBin="${HOME}/.xPro/bin"

export PATH="${xProBin}":$PATH

declare -A AppPointer=( [GitRepoDir]=$(xmllint --xpath "string(//GitRepoDir)" $HOME/.xPro/profile.xml) [ConfigFile]=$(xmllint --xpath "string(//ConfigFile)" $HOME/.xPro/profile.xml))
ConfigPath="${AppPointer[GitRepoDir]}/Config/Users${AppPointer[ConfigFile]}";

# Define alias
ProgramCount=$(xmllint --xpath "count(//Program)" ${ConfigPath});
for (( i=1; i<=$ProgramCount; i++ ))
do 
    ProgramString=$(xmllint --xpath "(//Program)[${i}]/text()" ${ConfigPath});
    alias=$(echo $(xmllint --xpath "(//Programs/Program/@Alias)[${i}]" ${ConfigPath}) | awk -F'[="]' '!/>/{print $(NF-1)}')
    alias ${alias}="$ProgramString";
done 


# Define modules
ModuleCount=$(xmllint --xpath "count(//Module)" ${ConfigPath});
for (( i=1; i<=$ModuleCount; i++ ))
do 
    ModuleString=$(xmllint --xpath "(//Module)[${i}]/text()" ${ConfigPath});
    source $ModuleString;
done 

# Define objects
declare -A magic_variable=()
ObjectCount=$(xmllint --xpath "count(//Object)" ${ConfigPath});
for (( i=1; i<=$ObjectCount; i++ ))
do 
    VarName=$(xmllint --xpath "(//Object/VarName)[${i}]/text()" ${ConfigPath});
    SimpleValue=$(xmllint --xpath "(//Object/SimpleValue)[${i}]/text()" ${ConfigPath});
    declare "$(echo $VarName)=$(echo $SimpleValue)";
done 

# Prompt
color=$(echo $(xmllint --xpath "(//ShellSettings/Prompt/String/@Color)" ${ConfigPath}) | awk -F'[="]' '!/>/{print $(NF-1)}')
PROMPT="%F{$color}$(xmllint --xpath "string(//ShellSettings/Prompt/String)" ${ConfigPath})%f"

# Start directory
cd $(xmllint --xpath "string(//ShellSettings/StartDirectory)" ${ConfigPath})
