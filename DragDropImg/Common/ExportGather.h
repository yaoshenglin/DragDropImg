//
//  ExportGather.h
//  iFace
//
//  Created by Yin on 16/2/25.
//  Copyright © 2016年 weicontrol. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const AddSlave;//上传从机
FOUNDATION_EXPORT NSString *const AddScene;//上传场景
FOUNDATION_EXPORT NSString *const GetLastVersions;//获取软件、硬件版本信息
FOUNDATION_EXPORT NSString *const AddFaceCustomDevice;//上传自定义设备
FOUNDATION_EXPORT NSString *const uploadFaceFamilys;//上传家庭组成员信息
FOUNDATION_EXPORT NSString *const AddFamily;//加入家庭组
FOUNDATION_EXPORT NSString *const UpdateFace;//上传场景图片
FOUNDATION_EXPORT NSString *const UpdateSceneImg;//上传场景图片
FOUNDATION_EXPORT NSString *const AddFaceCustumAC;//上传自定义空调
FOUNDATION_EXPORT NSString *const AddFaceCustomTV;//上传自定义电视
FOUNDATION_EXPORT NSString *const AddFaceCustomSTB;//上传自定义机顶盒
FOUNDATION_EXPORT NSString *const DownloadFamilyUser;//下载家庭成员信息
FOUNDATION_EXPORT NSString *const DownloadFamilyControl;//下载家庭组主机信息
FOUNDATION_EXPORT NSString *const DownloadFaceSlaveDevice;//下载家庭从机信息
FOUNDATION_EXPORT NSString *const DownloadFamilyScene;//下载家庭场景信息
FOUNDATION_EXPORT NSString *const DownloadFamilySceneControl;//下载家庭场景控制信息
FOUNDATION_EXPORT NSString *const DownloadFaceCustumAC;//下载自定义空调信息
FOUNDATION_EXPORT NSString *const DownloadFaceCustomTV;//下载自定义电视信息
FOUNDATION_EXPORT NSString *const DownloadFaceCustomSTB;//下载自定义机顶盒信息
FOUNDATION_EXPORT NSString *const DownloadFaceCustomDevice;//下载自定义设备
FOUNDATION_EXPORT NSString *const SelectTask;//定时任务、智能任务
FOUNDATION_EXPORT NSString *const UpdatenNickName;//更新昵称
FOUNDATION_EXPORT NSString *const CancelLogin;//退出登录
FOUNDATION_EXPORT NSString *const CreateFamilyVerify;//邀请成员加入家庭组
FOUNDATION_EXPORT NSString *const SendSMS;//发送短信(与验证码相关)
FOUNDATION_EXPORT NSString *const UpdateMoblie;//更换手机号码
FOUNDATION_EXPORT NSString *const BindingMoblie;//绑定手机号码
FOUNDATION_EXTERN NSString *const BindingMoblieAccordingChoice;//绑定多账号
FOUNDATION_EXPORT NSString *const UpRegistrationID;//注册远程通知ID
FOUNDATION_EXPORT NSString *const AddControl;//添加主机
FOUNDATION_EXPORT NSString *const CheckPermission;//验证权限
FOUNDATION_EXPORT NSString *const CrashInformation;//提交崩溃信息
FOUNDATION_EXPORT NSString *const QueryKeysWithKeyFile;//下载红外键值数据
FOUNDATION_EXPORT NSString *const KeyShare;//分享钥匙(门禁)
FOUNDATION_EXPORT NSString *const AddFaceOpenLockRecord;//上传开门记录(通用)
FOUNDATION_EXPORT NSString *const RemoveFamilyMember;//删除家庭成员
FOUNDATION_EXPORT NSString *const ExitFamily;//退出家庭组000
FOUNDATION_EXPORT NSString *const DismissFamily;//解散家庭组
FOUNDATION_EXPORT NSString *const Feedback;//提交反馈意见
FOUNDATION_EXPORT NSString *const QueryFaceOpenLockRecord;//查询开门记录
FOUNDATION_EXPORT NSString *const InitUser;//用户注册
FOUNDATION_EXPORT NSString *const QueryShareLock;//查询分享记录(门锁)
FOUNDATION_EXPORT NSString *const ShareLockEnable;//启用/禁用分享(门锁)
FOUNDATION_EXPORT NSString *const ClearShareLock;////清除失效分享记录(门锁)
FOUNDATION_EXPORT NSString *const GetShareLock;//获取分享链接(门锁)
FOUNDATION_EXPORT NSString *const LoginIFace;//iFace登录
FOUNDATION_EXPORT NSString *const DelTaskBySlaveCode;//删除从机定时、智能任务(全部相关)
FOUNDATION_EXPORT NSString *const DelFaceTimingTask;//删除定时任务(单个删除)
FOUNDATION_EXPORT NSString *const FaceTimingTaskCU;//添加定时任务
FOUNDATION_EXPORT NSString *const QueryFormatWithID;//下载格式模版数据
FOUNDATION_EXPORT NSString *const SetRemarkName;//修改备注名
FOUNDATION_EXPORT NSString *const RegisterIFace;//注册iFace账号
FOUNDATION_EXPORT NSString *const ResetIfacePwd;//修改账号密码
FOUNDATION_EXPORT NSString *const QueryBrands;//查询品牌
FOUNDATION_EXPORT NSString *const GetSlaveLastVersions;//获取从机设备版本号
FOUNDATION_EXPORT NSString *const QueryShare;//查询从机共享状态
FOUNDATION_EXPORT NSString *const UpdateShare;//更改从机共享状态
FOUNDATION_EXPORT NSString *const QueryCusRemoteShare;//查询自定义红外遥控共享状态
FOUNDATION_EXPORT NSString *const UpdateCusRemoteShare;//更改自定义红外遥控共享状态
FOUNDATION_EXPORT NSString *const GetWeiXinUserInfo;//微信登录时获得用户资料
FOUNDATION_EXPORT NSString *const QueryDoorLockUsers;//获取锁内用户备注列表
FOUNDATION_EXPORT NSString *const UpdateDoorLockUser;//更新锁内用户注册列表
FOUNDATION_EXPORT NSString *const RemoveDoorLockUser;//锁内用户删除操作
FOUNDATION_EXPORT NSString *const QueryVoipInfo;//获取voip服务器信息
FOUNDATION_EXPORT NSString *const UpdateVoipPushID;//更新VoIP推送token
FOUNDATION_EXPORT NSString *const QueryCommunityInfo;//查询小区信息
FOUNDATION_EXPORT NSString *const RemoteOpenDoor;//云门禁开门
//FOUNDATION_EXPORT NSString *const Add;//

@interface ExportGather : NSObject

@end
