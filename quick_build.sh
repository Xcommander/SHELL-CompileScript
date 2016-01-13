#!/bin/bash
WsRootDir=`pwd`
MY_NAME=`whoami`
CONFIGPATH=$WsRootDir/device/ginreen
KERNELCONFIGPATH=$WsRootDir/kernel-3.10/arch/arm64/configs
CUSTOMPATH=$WsRootDir/device/ginreen
RELEASEPATH=$1
ADDGMS=false
RELEASE_PARAM=all
LOG_PATH=$WsRootDir/build-log

CPUCORE=8

function get_make_command()
{
     echo command ./makeMtk
}

function makemk()
{
    local start_time=$(date +"%s")
    $(get_make_command) "$@"
    local ret=$?
    local end_time=$(date +"%s")
    local tdiff=$(($end_time-$start_time))
    local hours=$(($tdiff / 3600 ))
    local mins=$((($tdiff % 3600) / 60))
    local secs=$(($tdiff % 60))
    echo
        if [ $ret -eq 0 ] ; then
            echo -n -e "\033[34m #### make completed successfully \033[0m"
        else
            echo -n -e "\033[31m #### make failed to build some targets \033[0m"
        fi
        if [ $hours -gt 0 ] ; then
            printf "(%02g:%02g:%02g (hh:mm:ss))" $hours $mins $secs
        elif [ $mins -gt 0 ] ; then
            printf "(%02g:%02g (mm:ss))" $mins $secs
        elif [ $secs -gt 0 ] ; then
            printf "(%s seconds)" $secs
        fi
    echo -e "\033[31m #### \033[0m"
    echo
    return $ret
}

function build_version()
{
    #add produce verison
    #############################
    #version number
    #############################
    echo "********remove old version********"
       echo
    if [ -f "./version" ] ;then
       rm version
    fi

    VERSION=$WsRootDir/device/ginreen/${PRODUCT}/version
    if [ -f "$VERSION" ] ;then
       echo "***************copy new version***************"
       cp $VERSION .
       echo
    else
       echo "File version not exist!!!!!!!!!"
    fi
    INVER=`awk -F = 'NR==1 {printf $2}' version`
    OUTVER=`awk -F = 'NR==2 {printf $2}' version`
    PROVINCE=`awk -F = 'NR==3 {printf $2}' version`
    OPERATOR=`awk -F = 'NR==4 {printf $2}' version`
    INCREMENTALVER=`awk -F = 'NR==5 {printf $2}' version`	
    SVNUMBER=`awk -F = 'NR==6 {printf $2}' version`
    TIME=`date +%F`
    echo INNER VERSION IS $INVER
    echo OUTER VERSION IS $OUTVER
    echo PROVINCE NAME IS $PROVINCE
    echo OPERATOR NAME IS $OPERATOR
    echo RELEASE TIME IS $TIME
    echo INCREMENTAL VERSION IS $INCREMENTALVER	
    echo SV NUMBER IS $SVNUMBER
    export VER_INNER=$INVER
    export VER_OUTER=$OUTVER
    export PROVINCE_NAME=$PROVINCE
    export OPERATOR_NAME=$OPERATOR
    export RELEASE_TIME=$TIME
    export WIND_CPUCORES=$CPUCORE
    export VER_INCREMENTAL=$INCREMENTALVER
    export SV_NUMBER=$SVNUMBER	
    export WIND_PROJECT_NAME_CUSTOM=$CONFIG_NAME
}

PRODUCT=
VARIANT=
ACTION=
MODULE=
ORIGINAL=
COPYFILES=
CONFIG_NAME=

clean_pl()
{
    if [ x$ORIGINAL == x"yes" ]; then
        rm $LOG_PATH/pl.log; make clean-pl
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        PL_OUT_PATH=$OUT_PATH/obj/PRELOADER_OBJ
        rm -f $LOG_PATH/pl.log
        rm -f $OUT_PATH/preloader_$PRODUCT.bin
        rm -rf $PL_OUT_PATH
        result=$?
        return $result
    fi
}
build_pl()
{
    if [ x$ORIGINAL == x"yes" ]; then
        make -j$CPUCORE pl 2>&1 | tee $LOG_PATH/pl.log
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        PL_OUT_PATH=$OUT_PATH/obj/PRELOADER_OBJ
        cd bootable/bootloader/preloader
        PRELOADER_OUT=$PL_OUT_PATH TARGET_PRODUCT=$PRODUCT ./build.sh 2>&1 | tee $LOG_PATH/pl.log
        result=$?
        cd -
        cp $PL_OUT_PATH/bin/preloader_$PRODUCT.bin $OUT_PATH
        return $result
    fi
}

clean_kernel()
{
    if [ x$ORIGINAL == x"yes" ]; then
        rm $LOG_PATH/k.log; make clean-kernel
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        KERNEL_OUT_PATH=$OUT_PATH/obj/KERNEL_OBJ
        rm -f $LOG_PATH/k.log
        rm -f $OUT_PATH/boot.img
        rm -rf $KERNEL_OUT_PATH
        result=$?
        return $result
    fi
}
build_kernel()
{
    if [ x$ORIGINAL == x"yes" ]; then
        make -j$CPUCORE kernel 2>&1 | tee $LOG_PATH/k.log
        return $?
    else
        cd kernel-3.10
        if [ x$VARIANT == x"user" ] || [ x$VARIANT == x"userroot" ];then
            defconfig_files=${PRODUCT}_defconfig
        else
            defconfig_files=${PRODUCT}_debug_defconfig
        fi
        KERNEL_OUT_PATH=../out/target/product/$PRODUCT/obj/KERNEL_OBJ
        mkdir -p $KERNEL_OUT_PATH
        while [ 1 ]; do
            make O=$KERNEL_OUT_PATH ${defconfig_files}
            result=$?; if [ x$result != x"0" ];then break; fi
            #make -j$CPUCORE -k O=$KERNEL_OUT_PATH Image modules
            make -j$CPUCORE O=$KERNEL_OUT_PATH 2>&1 | tee $LOG_PATH/k.log
            result=$?; if [ x$result != x"0" ];then break; fi
            cp $KERNEL_OUT_PATH/arch/arm64/boot/Image.gz-dtb ../out/target/product/$PRODUCT/kernel
            break
        done
        cd -
        return $result
    fi
}

clean_lk()
{
    if [ x$ORIGINAL == x"yes" ]; then
        rm $LOG_PATH/lk.log; make clean-lk
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        LK_OUT_PATH=$OUT_PATH/obj/BOOTLOADER_OBJ
        rm -f $LOG_PATH/lk.log
        rm -f $OUT_PATH/lk.bin $OUT_PATH/logo.bin
        rm -rf $LK_OUT_PATH
        result=$?
        return $result
    fi
}
build_lk()
{
    if [ x$ORIGINAL == x"yes" ]; then
        make -j$CPUCORE lk 2>&1 | tee $LOG_PATH/lk.log
        return $?
    else
        OUT_PATH=$WsRootDir/out/target/product/$PRODUCT
        LK_OUT_PATH=$OUT_PATH/obj/BOOTLOADER_OBJ
        mkdir -p $LK_OUT_PATH
        cd bootable/bootloader/lk
        export BOOTLOADER_OUT=$LK_OUT_PATH
        export MTK_PUMP_EXPRESS_SUPPORT=yes
        make -j$CPUCORE $PRODUCT 2>&1 | tee $LOG_PATH/lk.log
        result=$?
        cd -
        cp $LK_OUT_PATH/build-$PRODUCT/lk.bin $OUT_PATH
        cp $LK_OUT_PATH/build-$PRODUCT/logo.bin $OUT_PATH
        return $result
    fi
}

function main()
{
    ##################################################################
    #Check parameters
    ##################################################################
    command_array=($1 $2 $3 $4 $5)
    if [ ! -d $LOG_PATH ];then
        mkdir $LOG_PATH
    fi
    for command in ${command_array[*]}; do

        ### set PRODUCT
        case $command in
            ginr6753_65c_l1)
            if [ x$PRODUCT != x"" ];then continue; fi
            PRODUCT=ginr6753_65c_l1
            RELEASEPATH=ginr6753_65c_l1
            continue
            ;;
            E169F_ASI)
            if [ x$PRODUCT != x"" ];then continue; fi
            PRODUCT=E169F
            RELEASEPATH=E169F
            CONFIG_NAME=$command
            continue
            ;;			
        esac

        ### set VARIANT
        if [ x$command == x"user" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=user
        elif [ x$command == x"debug" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=userdebug
        elif [ x$command == x"eng" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=eng
        elif [ x$command == x"userroot" ] ;then
            if [ x$VARIANT != x"" ];then continue; fi
            VARIANT=userroot
        ### set ACTION
        elif [ x$command == x"r" ] || [ x$command == x"remake" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=remake
        elif [ x$command == x"n" ] || [ x$command == x"new" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=new
        elif [ x$command == x"c" ] || [ x$command == x"clean" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=clean
            RELEASE_PARAM=none
        elif [ x$command == x"mmma" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=mmma
            RELEASE_PARAM=none
        elif [ x$command == x"mmm" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=mmm
            RELEASE_PARAM=none
        elif [ x$command == x"api" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=update-api
            RELEASE_PARAM=none
        elif [ x$command == x"boot" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=bootimage
            RELEASE_PARAM=boot
        elif [ x$command == x"system" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=systemimage
            RELEASE_PARAM=system
        elif [ x$command == x"userdata" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=userdataimage
            RELEASE_PARAM=userdata
        elif [ x$command == x"boot-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=bootimage-nodeps
            RELEASE_PARAM=boot
        elif [ x$command == x"snod" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=snod
            RELEASE_PARAM=system
        elif [ x$command == x"userdata-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=userdataimage-nodeps
            RELEASE_PARAM=userdata
        elif [ x$command == x"ramdisk-nodeps" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=ramdisk-nodeps
            RELEASE_PARAM=boot
        elif [ x$command == x"cache" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=cacheimage
            RELEASE_PARAM=none
        elif [ x$command == x"otapackage" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=otapackage
            RELEASE_PARAM=none
        elif [ x$command == x"otadiff" ];then
            if [ x$ACTION != x"" ];then continue; fi
            ACTION=otadiff
            RELEASE_PARAM=none
        elif [ x$command == x"cts" ];then	
            if [ x$ACTION != x"" ];then continue; fi	
            ACTION=cts	
            RELEASE_PARAM=none
        
        ### set ORIGINAL
        elif [ x$command == x"o" ];then
            if [ x$ORIGINAL != x"" ];then continue; fi
            ORIGINAL=yes

        ### set COPYFILES
        elif [ x$command == x"nc" ];then
            if [ x$COPYFILES != x"" ];then continue; fi
            COPYFILES=no

        ### set MODULE
        elif [ x$command == x"pl" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=pl
            RELEASE_PARAM=pl
        elif [ x$command == x"k" ] || [ x$command == x"kernel" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=k
            RELEASE_PARAM=boot
        elif [ x$command == x"lk" ];then
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=lk
            RELEASE_PARAM=lk
        #elif [ x$command == x"dr" ];then
            #if [ x$MODULE != x"" ];then continue; fi
            #MODULE=dr
            #RELEASE_PARAM=system
        else
            if [ x$MODULE != x"" ];then continue; fi
            MODULE=$command
        fi
    done

    if [ x$VARIANT == x"" ];then VARIANT=eng; fi
    if [ x$ORIGINAL == x"" ];then ORIGINAL=no; fi
    if [ x$ACTION == x"clean" ];then RELEASE_PARAM=none; fi
    if [ x$COPYFILES == x"" ];then
        if [ x$ACTION == x"new" ] && [ x$MODULE == x"" ];then
            COPYFILES=yes;
        else
            COPYFILES=no;
        fi
    fi

    echo "********This build project CONFIG_NAME is $CONFIG_NAME********"
    echo "PRODUCT=$PRODUCT VARIANT=$VARIANT ACTION=$ACTION MODULE=$MODULE COPYFILES=$COPYFILES ORIGINAL=$ORIGINAL"
    echo "Log Path $LOG_PATH"

    if [ x$PRODUCT == x"" ];then
        echo  -e "\033[31m !!!!!!   No Such Product   !!!! \033[0m"
        exit 1
    fi
    if [ x$ACTION == x"" ];then
        echo  -e "\033[31m !!!!!!   No Such Action   !!!! \033[0m"
        exit 1
    fi

    ##################################################################
    #Prepare
    ##################################################################
    Check_Space
    CUSTOM_FILES_PATH="./wind/custom_files"
    #shengbotao@wind-mobi.com 20150909 modify -s
    #if [ x$COPYFILES == x"yes" ];then copy_custom_files $PRODUCT; copy_custom_files_special $PRODUCT; fi
    if [ x$COPYFILES == x"yes" ];then copy_custom_files $PRODUCT; fi
    #shengbotao@wind-mobi.com 20150909 modify -e
    build_Project_Config $CONFIG_NAME
    #zhangheting@wind-mobi.com 20150720 modify -s
    build_Kernel_Config $CONFIG_NAME
    #zhangheting@wind-mobi.com 20150720 modify -e
    PROJECTNAME=`echo $CONFIG_NAME | sed -r 's/^[^_]*_//'`
    build_config $PROJECTNAME
    build_version
    export KERNEL_VER=zte-kernel
    #build_Common_Config
    
    ##################################################################
    #Add GMS
    ##################################################################
    if [ x"$ADDGMS" == x"true" ];then
        if [ x$ACTION == x"remake" ] || [ x$ACTION == x"new" ];then
            if [ x$MODULE == x"" ];then
                addGMS
            fi
        fi
    fi

    ###################################################################
    #Start build
    ###################################################################
    echo "Build started `date +%Y%m%d_%H%M%S` ..."
    echo;echo;echo;echo

    source build/envsetup.sh
    if [ x$VARIANT == x"userroot" ] ; then
        lunch full_$PRODUCT-user
    else    
        lunch full_$PRODUCT-$VARIANT
    fi    
    ##source mbldenv.sh
    ##source ./change_java.sh 1.7

    case $ACTION in
        new | remake | clean)

        M=false; C=false;
        if [ x$ACTION == x"new" ];then M=true; C=true;
        elif [ x$ACTION == x"remake" ];then M=true;
        else C=true;
        fi

        case $MODULE in
            pl)
            if [ x$C == x"true" ];then clean_pl; result=$?; fi
            if [ x$M == x"true" ];then build_pl; result=$?; fi
            ;;

            k)
            if [ x$C == x"true" ];then clean_kernel; result=$?; fi
            if [ x$M == x"true" ];then
                build_kernel; result=$?
                if [ $result -eq 0 ];then make -j$CPUCORE bootimage-nodeps; result=$?; fi
            fi
            ;;

            lk)
            if [ x$C == x"true" ];then clean_lk; result=$?; fi
            if [ x$M == x"true" ];then build_lk; result=$?; fi
            ;;

            *)
            if [ x"$MODULE" == x"" ];then
                if [ x$C == x"true" ];then make clean; rm $LOG_PATH; fi
                if [ x$M == x"true" ];then 
                    if [ x$VARIANT == x"userroot" ] ; then
                        echo "make userroot version"
                        make MTK_BUILD_ROOT=yes -j$CPUCORE 2>&1 | tee $LOG_PATH/build.log; result=$?; 
                    else
                        make -j$CPUCORE 2>&1 | tee $LOG_PATH/build.log; result=$?; 
                    fi
                fi
            else
                echo  -e "\033[31m !!!!!!   No Such module   !!!! \033[0m"
                exit 1
            fi
            ;;
        esac
        ;;
                
        mmma | mmm)
        $ACTION $MODULE 2>&1 | tee $LOG_PATH/$ACTION.log; result=$?
        ;;
        
        update-api | bootimage | systemimage | userdataimage | cacheimage | snod | bootimage-nodeps | userdataimage-nodeps | ramdisk-nodeps | otapackage | otadiff | cts)
        make -j$CPUCORE $ACTION 2>&1 | tee $LOG_PATH/$ACTION.log; result=$?
        ;;
    esac

    if [ $result -eq 0 ] && [ x$ACTION == x"mmma" -o x$ACTION == x"mmm" ];then
        echo "Start to release module ...."
        DIR=`echo $MODULE | sed -e 's/:.*//' -e 's:/$::'`
        NAME=${DIR##*/}
        TARGET=out/target/product/${PRODUCT}/obj/APPS/${NAME}_intermediates/package.apk
        if [ -f $TARGET ];then
            cp -f $TARGET /data/mine/test/MT6572/${MY_NAME}/${NAME}.apk
        fi
    elif [ $result -eq 0 ] && [ $RELEASE_PARAM != "none" ]; then
        echo "Build completed `date +%Y%m%d_%H%M%S` ..."
        echo "Start to release version ...."
        ./release_version.sh ${RELEASEPATH} ${RELEASE_PARAM}
    fi

}

function copy_custom_files()
{
    echo "Start copy files..."
    result=0
    case $1 in
        E169F)
        rm -rf vendor/mediatek/proprietary/custom/$PRODUCT/modem/mt6735_sp_lwg_dsds_CBON/*
        cp -a $CUSTOM_FILES_PATH/* ./
        result=$?
        ;;
        *)
        echo "!!!!!!   Nothing to copy   !!!!"
        ;;
    esac

    if [ $result -eq 1 ]; then
        echo -e "\033[31m Copy files error!!! \033[0m"
        exit 1
    else
        echo "Copy special files finish!"
    fi
}

function copy_custom_files_special()
{
    echo "Start copy special files... "    
    result=0
    case $1 in
        E169F_ASI)
        cp -a wind/custom_files_special/frameworks ./;
        result=$?
        ;;
        *)
        echo "!!!!!!   Nothing to copy   !!!!"
        ;;
    esac

    if [ $result -eq 1 ]; then
        echo -e "\033[31m Copy special files error!!! \033[0m"
        exit 1
    else
        echo "Copy special files finish!"
    fi
}

function build_Project_Config()
{    
    if [ x$1 == x"" ];then return; fi
    cp $WsRootDir/wind/custom_files/device/ginreen/$PRODUCT/ProjectConfig.mk $WsRootDir/device/ginreen/$PRODUCT/ProjectConfig.mk
    Config_File=$WsRootDir/wind/config/CONFIG_$1.mk
    Config_tmp=$WsRootDir/wind/config/CONFIG_$1_tmp
    Tmp_File=$WsRootDir/wind/config/file_tmp
    ProjectConfigFile=$WsRootDir/device/ginreen/$PRODUCT/ProjectConfig.mk
#    Common_File=$WsRootDir/wind/config/CONFIG_COMMON.mk

    if [ -f $Config_File ];then
        sed -i 's/[ ]*$//g' $ProjectConfigFile 
        sed -i '/^$/d' $ProjectConfigFile
        sed -i 's/\( \)\{1,\}/\1/g' $ProjectConfigFile
        sed -i 's/ =/=/g' $ProjectConfigFile
        grep -v "#" $Config_File > $Config_tmp
        sed -i '/^$/d' $Config_tmp 
        #export project define 
        ProConfig=`sed -n '/ProductConfig/,/ProEnd/{/ProductConfig/n;/ProEnd/b;p}' $Config_tmp`

	    OLDINF=$IFS
	    IFS=$'\n\n'
        for ProName  in $ProConfig; do
            export $ProName
        done
	    IFS=$OLDINF

        #ProjectConfig.mk main config 
        sed -n '/MainConfig/,/MainEnd/{/MainConfig/n;/MainEnd/b;p}' $Config_tmp > "$Tmp_File"
        Name=`sed 's/.*AUTO_ADD_GLOBAL_DEFINE_BY_NAME=//g' "$Tmp_File" | grep -v "="`
        sed -i 's/AUTO_ADD_GLOBAL_DEFINE_BY_NAME=.*/&'" ""$Name"'/' $ProjectConfigFile 

        NameValue=`sed 's/.*AUTO_ADD_GLOBAL_DEFINE_BY_NAME_VALUE=//g' "$Tmp_File" | grep -v "="`
        sed -i 's/AUTO_ADD_GLOBAL_DEFINE_BY_NAME_VALUE=.*/&'" ""$NameValue"'/' $ProjectConfigFile 

        Value=`sed 's/.*AUTO_ADD_GLOBAL_DEFINE_BY_VALUE=//g' "$Tmp_File" | grep -v "="`
        sed -i 's/AUTO_ADD_GLOBAL_DEFINE_BY_VALUE=.*/&'" ""$Value"'/' $ProjectConfigFile 

        #ProjectConfig.mk MTK config
        sed -n '/MTKConfig/,/MTKEnd/{/MTKConfig/n;/MTKEnd/b;p}' $Config_tmp > $Tmp_File 
        DelName=`sed 's/=.*//g' $Tmp_File`
        for DLname in $DelName; do
            sed -i '/'"$DLname"'.*'"="'/d' $ProjectConfigFile 
        done

        echo >> $ProjectConfigFile
        cat $Tmp_File >> $ProjectConfigFile
        #sed -n '/MTKConfig/,/MTKEnd/{/MTKConfig/n;/MTKEnd/b;p}' $Config_tmp >> $ProjectConfigFile 

        #ProjectConfig.mk NEW config
        sed -n '/NEWConfig/,/NEWEnd/{/NEWConfig/n;/NEWEnd/b;p}' $Config_tmp > $Tmp_File 
        DelName=`sed 's/=.*//g' $Tmp_File`
        for DLname in $DelName; do
#            Compare=`grep -wq $DLname $Common_File && echo "yes" || echo "no"` 
#            if [ $Compare = "no" ];then
#                echo "$Config_File $DLname not in $Common_File,Please Check!"
#                exit 1
#            fi
            sed -i '/'"$DLname"'.*'"="'/d' $ProjectConfigFile 
        done

        cat $Tmp_File >> $ProjectConfigFile
        #sed -n '/NEWConfig/,/NEWEnd/{/NEWConfig/n;/NEWEnd/b;p}' $Config_tmp >> $ProjectConfigFile 
        sed -i 's/[ ]*$//g' $ProjectConfigFile 
        rm $WsRootDir/wind/config/*_tmp
    else
        echo -e "\033[31m not  project config File!!! \033[0m"
        exit 1
    fi
}

function build_Common_Config()
{    
    Config_File=$WsRootDir/wind/config/CONFIG_COMMON.mk
    Config_tmp=$WsRootDir/wind/config/CONFIG_common_tmp
    Tmp_File=$WsRootDir/wind/config/file_tmp
    ProjectConfigFile=$WsRootDir/mediatek/config/common/ProjectConfig.mk

    if [ -f $Config_File ];then

        sed -i 's/[ ]*$//g' $ProjectConfigFile 
        sed -i '/^$/d' $ProjectConfigFile
        grep -v "#" $Config_File > $Config_tmp
        sed -i '/^$/d' $Config_tmp 

        #ProjectConfig.mk main config
        sed -n '/MainConfig/,/MainEnd/{/MainConfig/n;/MainEnd/b;p}' $Config_tmp > "$Tmp_File"
        Name=`sed 's/.*AUTO_ADD_GLOBAL_DEFINE_BY_NAME=//g' "$Tmp_File" | grep -v "="`
        sed -i 's/AUTO_ADD_GLOBAL_DEFINE_BY_NAME=.*/&'" ""$Name"'/' $ProjectConfigFile 

        NameValue=`sed 's/.*AUTO_ADD_GLOBAL_DEFINE_BY_NAME_VALUE=//g' "$Tmp_File" | grep -v "="`
        sed -i 's/AUTO_ADD_GLOBAL_DEFINE_BY_NAME_VALUE=.*/&'" ""$NameValue"'/' $ProjectConfigFile 

        Value=`sed 's/.*AUTO_ADD_GLOBAL_DEFINE_BY_VALUE=//g' "$Tmp_File" | grep -v "="`
        sed -i 's/AUTO_ADD_GLOBAL_DEFINE_BY_VALUE=.*/&'" ""$Value"'/' $ProjectConfigFile 

        #ProjectConfig.mk NEW config
        sed -n '/NEWConfig/,/NEWEnd/{/NEWConfig/n;/NEWEnd/b;p}' $Config_tmp > $Tmp_File 
        DelName=`sed 's/=.*//g' $Tmp_File`
        for DLname in $DelName; do
            #echo $DLname
            sed -i '/'"$DLname"'.*'"="'/d' $ProjectConfigFile 
        done

        echo >> $ProjectConfigFile
        cat $Tmp_File >> $ProjectConfigFile
        #sed -n '/NEWConfig/,/NEWEnd/{/NEWConfig/n;/NEWEnd/b;p}' $Config_tmp >> $ProjectConfigFile 

        sed -i 's/[ ]*$//g' $ProjectConfigFile 
        rm $WsRootDir/wind/config/*_tmp
    else
        echo -e "\033[31m not common config File!!! \033[0m"
        exit 1
    fi
}

function addGMS()
{
    if [ x$PRODUCT == x"E169F" ] ;then
    GMS=$WsRootDir/../GMS_Above5.0/gms-oem-lmp-5.1.1-signed-r2-20150610-1743759/google
    else
    GMS=$WsRootDir/../GMS_Above5.0/gms-oem-lmp-5.1.1-signed-r1-20150507-1743759/google
    fi
#zhangheting@wind-mobi.com modify 20150815 start
    
    CUSTOM_GMS_PATH=$WsRootDir/wind/custom_files/device/ginreen/$PRODUCT/google/google_r2

    if [ -d $GMS ];then
        echo "Remove old GMS"
        rm -fr vendor/google
        echo "Start to copy new GMS" 
        cp -a $GMS vendor/
		if [ -d $CUSTOM_GMS_PATH ] ;then
		  cp $CUSTOM_GMS_PATH/products/gms.mk $WsRootDir/vendor/google/products/gms.mk
		  if [ -d $CUSTOM_GMS_PATH/apps ] ;then
		    cp -a $CUSTOM_GMS_PATH/apps/Velvet $WsRootDir/vendor/google/apps/
		  fi
		  rm -rf $WsRootDir/device/ginreen/$PRODUCT/google
		fi
        echo "Complete copy new GMS"
    fi
#zhangheting@wind-mobi.com modify 20150815 end	
}

function build_config()
{
    FileName=$1
    compare_mk $CONFIGPATH/$PRODUCT/ custom.conf custom.conf_$FileName
    #compare_mk $CONFIGPATH/$PRODUCT/ init.usb.rc init.usb.rc_$FileName
    compare_mk $CUSTOMPATH/$PRODUCT/ version version$FileName
}

function Check_Space()
{
    UserHome=`pwd`
    Space=0
    Temp=`echo ${UserHome#*/}`
    Temp=`echo ${Temp%%/*}`
    ServerSpace=`df -lh $UserHome | grep "$Temp" | awk '{print $4}'`

    if echo $ServerSpace | grep -q 'G'; then
        Space=`echo ${ServerSpace%%G*}`
    elif echo $ServerSpace | grep -q 'T';then
        TSpace=1
    fi

    echo -e "\033[34m Log for Space $UserHome $ServerSpace $Space !!!\033[0m"
    if [ x"$TSpace" != x"1" ] ;then
        if [ "$Space" -le "30" ];then
            echo -e "\033[31m No Space!! Please Check!! \033[0m"
            exit 1
        fi  
    fi
}

function compare_mk()
{
    FilePath=$1
    oldfile=$2
    newfile=$3
    cd $FilePath
    
    if [ -f $newfile ] ; then
        diff $oldfile $newfile > diff.patch
    
        if [ $? == 0 ]; then
            echo  "These two files are same"
        else
            echo "Change $oldfile same as $newfile"
            rm $oldfile
            cp $newfile $oldfile
        fi
    fi
    
    if  [ -f diff.patch ] ; then
        rm diff.patch
    fi
    cd -
}

function checkout_vender()
{
  echo "Start check out vendor..."

  cd vendor
  rm -rf mediatek/$PRODUCT/artifacts/out/
  git checkout .
  cd -

  echo "Complete check out vendor !"
}

function build_Kernel_Config()
{
    if [ x$1 == x"" ];then return; fi

    cp $WsRootDir/wind/custom_files/kernel-3.10/arch/arm64/configs/${PRODUCT}_debug_defconfig $WsRootDir/kernel-3.10/arch/arm64/configs/${PRODUCT}_debug_defconfig
    cp $WsRootDir/wind/custom_files/kernel-3.10/arch/arm64/configs/${PRODUCT}_defconfig $WsRootDir/kernel-3.10/arch/arm64/configs/${PRODUCT}_defconfig

    config_debug=$WsRootDir/wind/config/CONFIG_KERNEL_DEBUG_$1.mk
    config=$WsRootDir/wind/config/CONFIG_KERNEL_$1.mk
    if [ ! -f $config_debug ] || [ ! -f $config ]; then
        config_debug=$WsRootDir/wind/config/CONFIG_KERNEL_DEBUG_${PRODUCT}.mk
        config=$WsRootDir/wind/config/CONFIG_KERNEL_${PRODUCT}.mk
    fi

    src_debug=$WsRootDir/kernel-3.10/arch/arm64/configs/${PRODUCT}_debug_defconfig
    src=$WsRootDir/kernel-3.10/arch/arm64/configs/${PRODUCT}_defconfig

    config_array=($config_debug $config)
    src_array=($src_debug $src)
    
    for (( i=0; i<2; i++ )); do
        config_file=${config_array[$i]}
        src_file=${src_array[$i]}
        
        if [ ! -f $src_file ] || [ ! -f $config_file ]; then
            echo -e "\033[31m error src_file or config_file is not exsit!!! \033[0m"
            exit 1
        fi
    
        #echo "$IFS" | od -b
        OLDINF=$IFS; IFS+=$'='
    
        while read paraa parab
        do
        	#echo "$paraa--$parab"
            flag=${paraa:0:2}; leng=${#flag}
            if [ x"$leng" == x"2" ]; then
                if [ x$flag == x"##" ]; then
                    #echo "is ## continue"
                    action=""; name=""; val=""
                    continue
                elif [[ x"$flag" == x#? ]]; then
                    #echo "is #? del"
                    action=del; name=${paraa#*#}; val=""
                else
                    #echo "is normal"
                    action=add_modify; name=$paraa; val=$parab
                fi
            elif [ x"$leng" == x"1" ]; then
                if [ x"$flag" == x"#" ]; then
                    #echo "is # del"
                    action=del; parab=${parab%%=*}; parab=${parab%%#*}; name=${parab%% *}; val=""
                else
                    echo -e "\033[31m error!!! \033[0m"
                    exit 1
                fi
            else
                #echo "continue"
                action=""; name=""; val=""
                continue
            fi
            #echo "$action--$name--$val"
    
            if [ x"$name" == x"" ] || [ x"$action" == x"" ]; then
                echo -e "\033[31m error name=null or action=null!!! \033[0m"
                exit 1
            fi
            
            line=`grep -nw "$name" $src_file | cut -d ":" -f 1`
            #echo "line=$line"
            
            if [ x"$action" == x"add_modify" ]; then
                if [ x"$line" != x"" ]; then
                    #echo "modify $line"
                    sed -i $line's/.*/'"$name"="$val"'/' $src_file
                else
                    #echo "add"
                    sed -i '$a'"$name"="$val" $src_file
                fi
            elif [ x"$action" == x"del" ]; then
                if [ x"$line" != x"" ]; then
                    #echo "del $line"
                    sed -i $line's/.*/# '"$name"' is not set/' $src_file
                fi
            else
                echo -e "\033[31m error action is not support!!! \033[0m"
                exit 1
            fi
        done < $config_file
        IFS=$OLDINF
    done
}

main $1 $2 $3 $4 $5

