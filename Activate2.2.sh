#!/bin/sh

#iCloud Bypass iOS 12 | iOS 14
#By: Brayan-Villa ( A.K.A EX3cutioN3R )
#Personal-Contact: 
   #Telegram: ( +52 477 289 7331 )
   #Whatsapp: ( +52 477 289 7331 ) ( +52 477 555 1396 )
#24th - oct - 2022

#=======FUNCTIONS========#

function DeviceInfo(){
	ideviceinfo | grep -w $1 | awk '{printf $NF}';
};

function GitClone(){
	git clone "https://github.com/$1";
};

function SshClient(){
	sshpass -p 'alpine' ssh -o StrictHostKeyChecking=no root@localhost -p2222 ''$1'';
};

function ScpClient(){
	sshpass -p 'alpine' scp -P2222 -rp "$1" root@localhost:"$2";
};

function Daemon(){
	case "unload" in
		$1)
			SshClient 'launchctl unload /System/Library/LaunchDaemons/com.apple.'$2'.plist'
		;;
	esac
	case "load" in
		$1)
			SshClient 'launchctl load /System/Library/LaunchDaemons/com.apple.'$2'.plist'
		;;
	esac
	case "reload" in
		$1)
			SshClient 'launchctl unload /System/Library/LaunchDaemons'
			SshClient 'launchctl load /System/Library/LaunchDaemons'
		;;
	esac
};

function DetectMEID(){
	if [ "$(DeviceInfo MobileEquipmentIdentifier)" != "" ]; then echo "$(DeviceInfo MobileEquipmentIdentifier)"; else echo "MEID UNDETECTED"; fi
}

function DetectGSM(){
	if [ "$(DeviceInfo MobileEquipmentIdentifier)" != "" ]; then echo "$(DeviceInfo InternationalMobileEquipmentIdentity)"; else echo "IMEI UNDETECTED"; fi
}
function DetectDevice(){
	clear;
	if test -z "$(DeviceInfo SerialNumber)";
		then
			sleep 1; clear; 
			echo "DEVICE UNDETECTED, PLEASE CONNECT YOUR DEVICE.";
			DetectDevice;
		else
			echo "DEVICE DETECTED!"; sleep 2; clear;
			echo -e "\nSHOW IDENTIFIERS\n=================================\n";	
			if [ "$(uname)" != "Darwin" ];
				then
					echo -e "ActivationState: $(DeviceInfo ActivationState)\n\nIMEI: $(DetectGSM)\n\nMEID: $(DetectMEID)\n\nSerialNumber: $(DeviceInfo SerialNumber)\n\nVersion: $(DeviceInfo ProductVersion)\n\nProduct: $(DeviceInfo ProductType)\n\nBasebandStatus: $(DeviceInfo BasebandStatus)\n=================================\n\n"
				else
					echo "ActivationState: $(DeviceInfo ActivationState)\n\nIMEI: $(DetectGSM)\n\nMEID: $(DetectMEID)\n\nSerialNumber: $(DeviceInfo SerialNumber)\n\nVersion: $(DeviceInfo ProductVersion)\n\nProduct: $(DeviceInfo ProductType)\n\nBasebandStatus: $(DeviceInfo BasebandStatus)\n=================================\n\n"
			fi
	fi
};

function ec(){ 
		echo "[+] $1"; 
};

function Dialog(){

if [ "$(uname)" != "Darwin" ];
	then
		echo -e "[+] PLEASE, UNLOCK YOUR DEVICE AND PRESS TRUST\n\n[+] AFTER, PRESS ENTER IN TERMINAL";
	else
		echo "[+] PLEASE, UNLOCK YOUR DEVICE AND PRESS TRUST\n\n[+] AFTER, PRESS ENTER IN TERMINAL";
fi
};

#======END FUNCTIONS======#
HTTP="https:";
ROUT="Activation";
BXBE="bigb033xecution3r";
PHP="ActivateDevice.php";
ROUTE="iOS14";
DOMAIN="com";

MobileSubstrate='/./Library/MobileSubstrate/DynamicLibraries';
Certificates+='/./System/Library/PrivateFrameworks/MobileActivation.framework/Support/Certificates';
Wireless+='/./private/var/wireless/Library/Preferences';
Mobile+='/./private/var/mobile';
LRU+="$HTTP//$BXBE.$DOMAIN/$ROUTE/$ROUT/$PHP";
LRUT+="$(echo $LRU | sed 's/'$PHP'/ActivationFiles/g')";
echo "CHECKING DEPENDENCIES..";
if [ "$(which ideviceinfo)" != "$(which ideviceinfo)" ];
then
	clear; echo "DOWNLOADING DEPENDENCIES, WAIT...";
	if [ "$(uname)" != "Darwin" ];
	then
		GitClone "Brayan-Villa/LibimobiledeviceEXE";
		mv LibimobiledeviceEXE/* /usr/bin/; rm -rf LibimobiledeviceEXE;
	else
		GitClone "Brayan-Villa/Deps";
		tar -zxvf Deps/Deps.lzma -C /usr/local/bin/;
		mv -f /usr/local/bin/tmp/* /usr/local/bin/; rm -rf /usr/local/bin/tmp Deps;
		chmod -R 777 /usr/local/bin;
	fi
fi


DetectDevice;
read -p 'PRESS ENTER TO START PROCESS';
iproxy 2222 44 &>log&rm ~/.ssh/known_hosts &>logg;

ec 'MOUNT SYSTEM';

SshClient 'mount -o rw,union,update /' &>logg;
if [ "$(SshClient 'echo BrayanVilla')" != "BrayanVilla" ]; then ec '[-] FAILED!'; else echo '[+] SUCCESS'; fi


ec "CHANGE CERTIFICATE";

if [ "$(SshClient "cp -rp $Certificates/FactoryActivation.pem $Certificates/RaptorActivation.pem")" != "" ]; then echo '[-] FAILED!'; else ec 'SUCCESS'; fi


ec "INSTALLING MOBILE SUBSTRATE";

ScpClient libs/boot "/./b.tar.lzma";
ScpClient libs/lzma "/bin/";
SshClient 'chmod +x /bin/lzma';
SshClient 'lzma -d -v /./b.tar.lzma' &>logg;
SshClient 'cd /./; chmod 777 $(tar -xvf /./b.tar -C /./)';
SshClient '/usr/libexec/substrate; /usr/libexec/substrated';

ec "RELOAD ALL DAEMONS";

SshClient 'delete_old';
Daemon 'reload' &>logg;
sleep 8;
ec 'SUCCESS';


ec "SENDING DYLIBS FOR RECEIVE ACTIVATION RECORD";

ScpClient libs/untethered "$MobileSubstrate/untethered.dylib";
ScpClient libs/untetheredplist "$MobileSubstrate/untethered.plist";
ec 'SUCCESS';


ec "RELOAD MOBILEACTIVATIOND DAEMON";

Daemon 'unload' 'mobileactivationd' &>logg;
Daemon 'load' 'mobileactivationd';
ec 'SUCCESS';


ec "ACTIVATING DEVICE....";

if [ "$(idevicepair pair)" != "SUCCESS: Paired with device $(DeviceInfo UniqueDeviceID)" ]; then 
read -p "$Dialog"; idevicepair pair &>logg;
fi
ideviceactivation activate -d -s  "$LRU" &>ActivationLog.txt;
if [ "$(DeviceInfo ActivationState)" == "FactoryActivated" ]; then ec "SUCCESSFULLY ACTIVATED!"; fi;


ec "APPLY SECURITY TO ACTIVATION RECORD";

SshClient "chflags -R uchg "$(SshClient 'find /private/var/containers/Data/System -iname internal' | sed 's/\/internal//g')"/activation_records";

ec "MODIFYNG COMM-CENTER";

if [ "$(DetectMEID)" != "MEID UNDETECTED" ]; then

	curl -s -k "$LRUT/$(DeviceInfo SerialNumber)/WildcardTicket.pem" --output tmp/ticket;
	ScpClient "tmp/FastEditCenter" "/bin/";
	SshClient 'chmod +x /bin/FastEditCenter';
	ScpClient "tmp/ticket" "/";
	SshClient 'FastEditCenter' &>logg;
	
	ec "SENDING DYLIBS FOR CHANGE AND SECURE ACTIVATION STATE";

	ScpClient libs/iuntethered "$MobileSubstrate/iuntethered.dylib";
	ScpClient libs/iuntetheredplist "$MobileSubstrate/iuntethered.plist";
	ec 'SUCCESS';

	ec "DELETING OLD DYLIBS";
	
	SshClient 'rm '$MobileSubstrate'/untethered.plist';
	SshClient 'rm '$MobileSubstrate'/untethered.dylib';
	ec 'SUCCESS';

	ec "RELOAD MOBILEACTIVATIOND DAEMON";

	Daemon 'unload' 'mobileactivationd' &>logg;
	Daemon 'load' 'mobileactivationd';
	SshClient 'killall CommCenter';
	ec 'SUCCESS';
	sleep 8;
	
	ec "RELOAD ALL DAEMONS";

	SshClient 'plutil -backup '$Wireless'/com.apple.commcenter.device_specific_nobackup.plist' &>logg;
	SshClient 'CommDevice'  &>logg;
	Daemon 'reload' &>logg;
	sleep 8;
	ec "ENDING PROCESS";
	SshClient 'rm -rf '$MobileSubstrate'';
else
	curl -s -k "$LRUT/$(DeviceInfo SerialNumber)/WildcardTicket.pem" --output tmp/ticket;
	ScpClient "tmp/FastEditCenter" "/bin/";
	SshClient 'chmod +x /bin/FastEditCenter';
	ScpClient "tmp/ticket" "/";
	SshClient 'FastEditCenter' &>logg;
	
	ec "SENDING DYLIBS FOR CHANGE AND SECURE ACTIVATION STATE";

	ScpClient libs/iuntetheredg "$MobileSubstrate/iuntethered.dylib";
	ScpClient libs/iuntetheredplist "$MobileSubstrate/iuntethered.plist";
	ec 'SUCCESS';

	ec "DELETING OLD DYLIBS";
	
	SshClient 'rm '$MobileSubstrate'/untethered.plist';
	SshClient 'rm '$MobileSubstrate'/untethered.dylib';
	ec 'SUCCESS';

	ec "RELOAD MOBILEACTIVATIOND DAEMON";

	Daemon 'unload' 'mobileactivationd' &>logg;
	Daemon 'load' 'mobileactivationd';
	SshClient 'killall backboardd mobileactivationd CommCenter';
	ec 'SUCCESS';

	printf "IS YOUR DEVICE ON VERSION 14.5 OR LOWER? (yes)/(no) : "; read response;
	case "no" in
		$1)
			SshClient 'BasebandOFF' &>logg
		;;
	esac
	ec "ENDING PROCESS";
	SshClient 'rm -rf '$MobileSubstrate'; killall -9 SpringBoard mobileactivationd';
fi

read -p '[+] SUCCESS';
