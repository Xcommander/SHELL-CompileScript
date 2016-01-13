#!/bin/bash

###############################   �û������趨�� ��ʼ  ############################################
#ʹ��˵�����뽫�˽ű����ڴ����Ŀ¼�£���.repoͬ��Ŀ¼����ִ�д˽ű������Զ����ƻ�Ŀ¼���ļ���
#          ��Щ����ֻ��������Ŀ��ƻ�������֤�ܱ���ͨ�������������Ķ��ƣ�����Ҫ�ֶ��޸ġ��ű�
#          ִ�к���Ҫ�ֶ���ӻ��޸�release_version.sh��quick_build.sh��version�����ļ���������
#          ����һ�Σ�ȷ���������ϴ����롣�����ʲô���⣬����ϵ�ҡ�
##################################################################################################
SRC_NAME=ginr6735_66t_l1          #ԴĿ¼��
TARGET_NAME=E167L         #Ŀ��Ŀ¼��

###############################   �û������趨�� ����  ############################################







###############################   �ű����������𶯣� ��ʼ  ############################################

CUSTOM_PROJECT_PATH=wind/custom_files

function main()
{
echo -e "\033[36m/****************************************************************************/\033[0m"
echo -e "\033[36m/*                                                                          */\033[0m"
echo -e "\033[36m/*                               Auto Custom                                */\033[0m"
echo -e "\033[36m/*                                         ---V0.1  by libing               */\033[0m"
echo -e "\033[36m/*                                                                          */\033[0m"
echo -e "\033[36m/****************************************************************************/\033[0m"

echo ""

echo "1.copy files"

###01
COPY_FILES_PATH=device/ginreen
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/$SRC_NAME ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME
###02
mv ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME/full_${SRC_NAME}.mk ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME/full_${TARGET_NAME}.mk
###03
COPY_FILES_PATH=vendor/mediatek/proprietary/trustzone/project
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/$SRC_NAME.mk ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME.mk
###04
COPY_FILES_PATH=vendor/mediatek/proprietary/custom
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/$SRC_NAME ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME
###05
COPY_FILES_PATH=vendor/ginreen/libs
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/$SRC_NAME ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME
###06
COPY_FILES_PATH=kernel-3.10/arch/arm64/configs
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/${SRC_NAME}_defconfig ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/${TARGET_NAME}_defconfig
###07
COPY_FILES_PATH=kernel-3.10/arch/arm64/configs
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/${SRC_NAME}_debug_defconfig ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/${TARGET_NAME}_debug_defconfig
###08
COPY_FILES_PATH=kernel-3.10/arch/arm64/boot/dts
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/$SRC_NAME.dts ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME.dts
###09
COPY_FILES_PATH=kernel-3.10/drivers/misc/mediatek/mach/mt6735
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/$SRC_NAME ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME
###10
COPY_FILES_PATH=bootable/bootloader/preloader/custom
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/$SRC_NAME ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME
###11
mv ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME/$SRC_NAME.mk ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME/$TARGET_NAME.mk
###12
COPY_FILES_PATH=bootable/bootloader/lk/target
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/$SRC_NAME ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME
###13
COPY_FILES_PATH=bootable/bootloader/lk/project
mkdir -p ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH
cp -a ./$COPY_FILES_PATH/$SRC_NAME.mk ./$CUSTOM_PROJECT_PATH/$COPY_FILES_PATH/$TARGET_NAME.mk

echo "1.Done"

echo ""

echo "2.modify char"
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/vendor/mediatek/proprietary/custom/$TARGET_NAME/Android.mk
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/vendor/ginreen/libs/$TARGET_NAME/device-vendor.mk
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/device/ginreen/$TARGET_NAME/AndroidProducts.mk
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/device/ginreen/$TARGET_NAME/full_$TARGET_NAME.mk
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/device/ginreen/$TARGET_NAME/device.mk
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/device/ginreen/$TARGET_NAME/BoardConfig.mk
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/device/ginreen/$TARGET_NAME/vendorsetup.sh
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/bootable/bootloader/lk/project/$TARGET_NAME.mk
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/bootable/bootloader/preloader/custom/$TARGET_NAME/$TARGET_NAME.mk
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/kernel-3.10/arch/arm64/configs/${TARGET_NAME}_debug_defconfig
sed -i 's/'"$SRC_NAME"'/'"$TARGET_NAME"'/g' ./$CUSTOM_PROJECT_PATH/kernel-3.10/arch/arm64/configs/${TARGET_NAME}_defconfig
echo "2.Done"

echo ""

echo "Please modify this file manually."
echo "1./vendor/wind/scripts/release_version.sh"
echo "2./vendor/wind/scripts/quick_build.sh"
#echo "3./mediatek/custom/$TARGET_NAME/version"

echo ""

}

main $1 $2

###############################   �ű����������𶯣� ����  ############################################
