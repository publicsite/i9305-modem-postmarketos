#!/bin/sh

thepwd="$PWD"

if [ ! -d kernelArchives ]; then
mkdir kernelArchives
fi

if [ "$1" != "" ] && [ -d "postmarketConfigs/$1" ]; then
akernel="$1"
else
while true; do
echo "TYPE YOUR KERNEL!\n$( cd postmarketConfigs; find . -mindepth 1 -maxdepth 1 -type d | cut -d / -f2 | sort )" | less
read akernel
if [ -d "postmarketConfigs/$akernel" ]; then
	echo "You chose $akernel"
	break
elif [ "$akernel" = "q" ]; then
	echo "User quit."
	exit 1
fi
done
fi

chmod +x postmarketConfigs/$akernel/APKBUILD

if [ ! -f "postmarketConfigs/$akernel/APKBUILD.old" ]; then
	cp -a postmarketConfigs/$akernel/APKBUILD postmarketConfigs/$akernel/APKBUILD.old
	sed -i "s#builddir=.*linux-.*##g" postmarketConfigs/$akernel/APKBUILD
	echo "" >> postmarketConfigs/$akernel/APKBUILD
	echo "echo \"\$source"\" >> postmarketConfigs/$akernel/APKBUILD
	sed -i 's#${pkgver//_/-}#${pkgver}#g' postmarketConfigs/$akernel/APKBUILD
fi

sources="$(./postmarketConfigs/$akernel/APKBUILD)"

kernelroot=""
IFS="	
"
for line in $sources; do

	if [ "$line" != "" ]; then
		line="$(echo "$line" | sed 's/^[ \t]*//;s/[ \t]*$//' | sed "s/.*:://g" )"

		theprefix="$( echo "$line" | cut -d : -f 1 )"

		if [ "$theprefix" = "https" ] || [ "$theprefix" = "http" ] | [ "$theprefix" = "git" ]; then
			extension="$( echo "$line" | rev | cut -d . -f 1 | rev )"
			thefilename="$( echo "$line" | rev | cut -d / -f 1 | rev )"
			noextension="$( echo "$thefilename" | cut -d . -f 1)"

			if [ "$extension" = "xz" ] || [ "$extension" = "gz" ] || [ "$extension" = "zip" ] || [ "$extension" = "bz2" ]; then

				if [ ! -f "./postmarketConfigs/$akernel/$line" ]; then
					if [ ! -f "kernelArchives/$thefilename" ]; then
						wget "$line" -O "kernelArchives/$thefilename"
						if [ "$?" -gt 0 ]; then
							rm "kernelArchives/$thefilename"
						fi
					fi
				fi

				if [ -d "kernelArchives/$noextension" ]; then
					rm -rf "kernelArchives/$noextension"
				fi

				mkdir "kernelArchives/$noextension"
				cd "kernelArchives/$noextension"
				tar -xf ../"$thefilename"
				if [ "$?" -gt 0 ]; then
					cd ../../
					rm -rf "kernelArchives/$noextension"
				else
					cd ../../
				fi

				if [ "$kernelroot" = "" ]; then
					kernelroot="$PWD/kernelArchives/$noextension"
				fi
			else
				if [ ! -d "kernelArchives/$noextension" ]; then
					git clone "$line" "kernelArchives/$noextension"
					if [ "$?" -gt 0 ]; then
						rm -rf "kernelArchives/$noextension"
					fi
				fi

				if [ "$kernelroot" = "" ]; then
					kernelroot="$PWD/kernelArchives/$noextension"
				fi
			fi
		fi
	fi
done

cd "$kernelroot"

while true; do
	if [ -f README ]; then

		break
	else
		tosink="$(find .  -maxdepth 1 -mindepth 1 -type d | head -n 1)"
		if [ "$tosink" = "" ]; then
			break
		else
			cd "$tosink"
		fi
	fi
done

kernelroot="$PWD"

find "$thepwd/postmarketConfigs/$akernel" -type f -name "*.patch" | sort | while read line; do
patch -p1 < "$line"
done



