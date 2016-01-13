#!/bin/bash
build_param=$1
release_param=$2

if [ x"$build_param" = "x" ];then
    echo "Usage: command [build_param]. e.g. command l300"
    return 1
fi

if [ x"$release_param" = "x" ];then
   release_param=all
fi

ROOT=`pwd`
OUT_PATH=$ROOT"/out/target/product"
MY_NAME=`whoami`
HARDWARE_VER=S01
PLATFORM=MT6735

case $build_param in
    ginr6753_65c_l1)
        HARDWARE_VER=S01
        OUT_PATH=$OUT_PATH/ginr6753_65c_l1
        build_param=ginr6753_65c_l1
        PLATFORM=MT6753
        ;;
    E169F)
        HARDWARE_VER=WXKMA1A1-1
        OUT_PATH=$OUT_PATH/E169F
        build_param=E169F
        PLATFORM=MT6735M
        ;;	
    *)
        echo "no such project!!"
        exit 1
        ;;
esac

if [ ! -d $OUT_PATH ];then
    echo "ERROR: there is no out path:$OUT_PATH"
    return
fi

if [ x"$release_param" = x"all" ]; then
    for i in "$OUT_PATH/system/etc/mddb/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9*_ltg_n" ; do
        if [ -f $i ]; then
            cp $i  $OUT_PATH/Modem_Database_ltg
        fi
    done
    for i in "$OUT_PATH/system/etc/mddb/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9*_lwg_n" ; do
        if [ -f $i ]; then
            cp $i  $OUT_PATH/Modem_Database_lwg
        fi
    done
    for i in "$OUT_PATH/obj/CGEN/APDB_MT6735_"$HARDWARE_VER"_L1.MP3_W15.4?" ; do
        if [ -f $i ]; then
            cp $i $OUT_PATH/AP_Database
        fi
    done    
fi

if [ ! -f $OUT_PATH/Modem_Database_ltg ];then
    ALL_RELEASE_FILES="logo.bin $PLATFORM"_Android_scatter.txt" preloader_$1.bin AP_Database Modem_Database_lwg boot.img secro.img userdata.img system.img lk.bin recovery.img cache.img trustzone.bin"
elif [ ! -f $OUT_PATH/Modem_Database_lwg ];then
    ALL_RELEASE_FILES="logo.bin $PLATFORM"_Android_scatter.txt" preloader_$1.bin AP_Database Modem_Database_ltg boot.img secro.img userdata.img system.img lk.bin recovery.img cache.img trustzone.bin"
else
    ALL_RELEASE_FILES="logo.bin $PLATFORM"_Android_scatter.txt" preloader_$1.bin AP_Database Modem_Database_ltg Modem_Database_lwg boot.img secro.img userdata.img system.img lk.bin recovery.img cache.img trustzone.bin"
fi

case $release_param in
    all)
        RELEASE_FILES=$ALL_RELEASE_FILES
        ;;
    system)
        RELEASE_FILES="system.img"
        ;;
    boot)
        RELEASE_FILES="boot.img"
        ;;
    lk)
        RELEASE_FILES="lk.bin"
        ;;
    logo)
        RELEASE_FILES="logo.bin"
        ;;
    userdata)
        RELEASE_FILES="userdata.img"
        ;;
    pl)
        RELEASE_FILES="preloader_$1.bin"
        ;;
    none)
        ;;		
    *)
        echo "not supported!!"
        exit 1
        ;;
esac

FILES=""
for file in $RELEASE_FILES; do
    if [ x"$file" == x"system.img" ] ;then
        filesize=`ls -lk $OUT_PATH/$file | awk '{print $5}'`
        echo "$file ---- $filesize KB"
    else
        echo "$file"
    fi
    FILES=$FILES" "$OUT_PATH"/"$file
done

cp $FILES /data/mine/test/MT6572/$MY_NAME/

echo "Sucess!"
