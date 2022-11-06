while getopts "t:" opt; do
  case $opt in
    t) target=$OPTARG
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z ${target} ]; then
    echo "Error: no target"
    exit
fi

# Lyres Dictionary Site

mkdir $target/projects/lyres-dictionary
cp -r repositories/lyre-site/_site/* $target/projects/lyres-dictionary
cp -r repositories/lyre-site/_site/assets $target/projects/lyres-dictionary
