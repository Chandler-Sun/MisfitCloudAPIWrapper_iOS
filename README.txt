# MisfitCloudAPIWrapper_iOS
iOS wrapper for Misfit Cloud API
如果使用了自己的网络库,为了减小最终包大小, 请将MFCAPIClient中的网络操作替换为自己的网络库,再重新编译. 否则可直接使用编译好的frameworks (解压MisfitCloudAPI.wrapper.bin.zip)

此外:

将下列frameworks添加到你的项目中:

MobileCoreServices.framework
SystemConfiguration.framework