//
//  ExportGather.m
//  iFace
//
//  Created by Yin on 16/2/25.
//  Copyright © 2016年 weicontrol. All rights reserved.
//

#import "ExportGather.h"


NSString *const AddSlave = @"AddSlaveExtShare";
NSString *const AddScene = @"AddSceneV2";//上传场景
NSString *const AddFaceCustomDevice = @"AddFaceCustomDeviceExtShare";//上传自定义设备
NSString *const GetLastVersions = @"GetLastVersions";//获取软件、硬件版本信息
NSString *const uploadFaceFamilys = @"uploadFaceFamilys";//上传家庭组成员信息
NSString *const AddFamily = @"AddFamily";//加入家庭组
NSString *const UpdateFace = @"UpdateFace";//上传场景图片
NSString *const UpdateSceneImg = @"UpdateSceneImg";//上传场景图片
NSString *const AddFaceCustumAC = @"AddFaceCustumAC";//上传自定义空调
NSString *const AddFaceCustomTV = @"AddFaceCustomTV";//上传自定义电视
NSString *const AddFaceCustomSTB = @"AddFaceCustomSTB";//上传自定义机顶盒
NSString *const DownloadFamilyUser = @"DownloadFamilyUser";//下载家庭成员信息
NSString *const DownloadFamilyControl = @"DownloadFamilyControl";//下载家庭组主机信息
NSString *const DownloadFaceSlaveDevice = @"DownloadFaceSlaveDevice";//下载家庭从机信息
NSString *const DownloadFamilyScene = @"DownloadFamilyScene";//下载家庭场景信息
NSString *const DownloadFamilySceneControl = @"DownloadFamilySceneControl";//下载家庭场景控制信息
NSString *const DownloadFaceCustumAC = @"DownloadFaceCustumAC";//下载自定义空调信息
NSString *const DownloadFaceCustomTV = @"DownloadFaceCustomTV";//下载自定义电视信息
NSString *const DownloadFaceCustomSTB = @"DownloadFaceCustomSTB";//下载自定义机顶盒信息
NSString *const DownloadFaceCustomDevice = @"DownloadFaceCustomDevice";//下载自定义设备
NSString *const SelectTask = @"SelectTask";//定时任务、智能任务
NSString *const UpdatenNickName = @"UpdatenNickName";//更新昵称
NSString *const CancelLogin = @"Logout";//退出登录
NSString *const CreateFamilyVerify = @"CreateFamilyVerify";//邀请成员加入家庭组
NSString *const SendSMS = @"SendSMS";//发送短信(与验证码相关)
NSString *const UpdateMoblie = @"UpdateMoblie";//更换手机号码
NSString *const BindingMoblie = @"BindingMoblie";//绑定手机号码
NSString *const BindingMoblieAccordingChoice = @"BindingMoblieAccordingChoice";//绑定多账号
NSString *const UpRegistrationID = @"UpRegistrationID";//注册远程通知ID
NSString *const AddControl = @"AddControl";//添加主机
NSString *const CheckPermission = @"CheckPermission_V2";//验证权限CheckPermission_V2
NSString *const CrashInformation = @"CrashInformation_V2";//提交崩溃信息
NSString *const QueryKeysWithKeyFile = @"QueryKeysWithKeyFile";//下载红外键值数据
NSString *const KeyShare = @"KeyShare";//分享钥匙(门禁)
NSString *const AddFaceOpenLockRecord = @"AddFaceOpenLockRecord";//上传开门记录(通用)
NSString *const RemoveFamilyMember = @"RemoveFamilyMember";//删除家庭成员
NSString *const ExitFamily = @"ExitFamily";//退出家庭组
NSString *const DismissFamily = @"DismissFamilyV2";//解散家庭组
NSString *const Feedback = @"Feedback";//提交反馈意见
NSString *const QueryFaceOpenLockRecord = @"QueryFaceOpenLockRecord";//查询开门记录
NSString *const InitUser = @"InitUser_V2";//用户注册
NSString *const QueryShareLock = @"QueryShareLock";//查询分享记录(门锁)
NSString *const ShareLockEnable = @"ShareLockEnable";//启用/禁用分享(门锁)
NSString *const ClearShareLock = @"ClearShareLock";////清除失效分享记录(门锁)
NSString *const GetShareLock = @"ShareLock";//获取分享链接(门锁)
NSString *const LoginIFace = @"LoginIFace";//iFace登录
NSString *const DelTaskBySlaveCode = @"DelTaskBySlaveCode";//删除从机定时、智能任务(全部相关)
NSString *const DelFaceTimingTask = @"DelFaceTimingTask";//删除定时任务(单个删除)
NSString *const FaceTimingTaskCU = @"FaceTimingTaskCU";//添加定时任务
NSString *const QueryFormatWithID = @"QueryFormatWithID";//下载格式模版数据
NSString *const SetRemarkName = @"SetRemarkName";//修改备注名
NSString *const RegisterIFace = @"RegisterIFace";//注册iFace账号
NSString *const ResetIfacePwd = @"ResetIfacePwd";//修改账号密码
NSString *const QueryBrands = @"QueryBrands";//查询品牌
NSString *const GetSlaveLastVersions = @"GetSlaveLastVersions";//获取从机设备版本号
NSString *const QueryShare = @"QueryShare";//查询从机共享状态
NSString *const UpdateShare = @"UpdateShare";//更改从机共享状态
NSString *const QueryCusRemoteShare = @"QueryCusRemoteShare";//查询自定义红外遥控共享状态
NSString *const UpdateCusRemoteShare = @"UpdateCusRemoteShare";//更改自定义红外遥控共享状态
NSString *const GetWeiXinUserInfo = @"GetWeiXinUserInfo";//微信登录时获得用户资料
NSString *const QueryDoorLockUsers = @"QueryDoorLockUsers";//获取锁内用户备注列表
NSString *const UpdateDoorLockUser = @"UpdateDoorLockUser";//更新锁内用户注册列表
NSString *const RemoveDoorLockUser = @"RemoveDoorLockUser";//锁内用户删除操作
NSString *const QueryVoipInfo = @"QueryVoipInfo";//获取voip服务器信息
NSString *const UpdateVoipPushID = @"UpdateVoipPushID";//更新VoIP推送token
NSString *const QueryCommunityInfo = @"QueryCommunityInfo";//查询小区信息
NSString *const RemoteOpenDoor = @"RemoteOpenDoor";//云门禁开门
//NSString *const Add = @"Add";//

@implementation ExportGather

@end
