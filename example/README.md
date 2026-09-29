# flutter_wot_ui_example

`flutter_wot_ui` 的示例应用，展示组件库各组件的能力与接入方式。

## 多商店一键上传

项目内置 [apkgo](https://github.com/KevinGong2013/apkgo)（v3.7.3），一行命令将 APK 并发上传到 **蒲公英 + 国内安卓各大应用商店**（华为 AppGallery、小米、OPPO、vivo、腾讯应用宝、荣耀）。

### 目录结构

```
example/
├── apkgo.yaml              # 商店密钥配置（必填字段已空着，自行填入，不提交）
├── scripts/
│   └── upload.ps1          # 一键上传脚本
```

### 一、在各商店后台创建应用（一次性前置）

所有商店上传前必须先在对应开发者后台**注册账号 + 创建应用**，否则 API 上传会被拒绝。

| 商店 | 创建应用地址 | 是否可以跳过创建直接上传 |
|---|---|---|
| **蒲公英** | <https://www.pgyer.com/app/add> | ✅ **可以跳过** — API 会根据包名自动创建应用 |
| **华为 AppGallery** | <https://developer.huawei.com/consumer/cn/console/appgallery/app/add> | ❌ 必须先创建（包名白名单） |
| **小米** | <https://dev.mi.com/xiaomihyperos/console/app/add> | ❌ 必须先创建 |
| **OPPO** | <https://open.oppomobile.com/new/console/app/add> | ❌ 必须先创建 |
| **vivo** | <https://dev.vivo.com.cn/console/app/add> | ❌ 必须先创建 |
| **腾讯应用宝** | <https://open.qq.com/console/app/create> | ❌ 必须先创建 |
| **荣耀** | <https://developer.honor.com/cn/console/app/add> | ❌ 必须先创建 |

> 各商店创建应用时，**包名（Package Name）必须和 `android/app/src/main/AndroidManifest.xml` 里的 `applicationId` 完全一致**。应用名称、图标、简介等信息按提示填即可。部分商店创建后需要等待基础审核通过（一般几小时到一两天），审核通过后才能申请 API 密钥。

### 二、填写密钥

打开 `apkgo.yaml`，把需要的商店字段填上。不需要的商店整段删掉即可。

如果新设备上没有 `apkgo.yaml`（因为它被 `.gitignore` 忽略了），复制下面的模板保存为 `example/apkgo.yaml`，**把要开启的商店去掉 `#` 注释，填入真实密钥**：

```yaml
# apkgo 配置模板（完整路径：example/apkgo.yaml）
# 所有商店默认注释掉，把要开启的商店段落取消注释并填入密钥即可

stores:
  # --- 内测分发 ---
  pgyer:
    api_key: ""   # https://www.pgyer.com/account/api

  # fir:
  #   api_token: ""  # https://fir.im → 控制台 → 账号 → API Token

  # --- 国内安卓商店（都需要先在对应开发者后台创建应用） ---

  # huawei:
  #   service_account: ""              # 推荐方式：Service Account JSON 或 base64
  #   service_account_file: ""         # 或：Service Account JSON 文件路径
  #   client_id: ""                    # 已弃用，逐步迁移到 Service Account
  #   client_secret: ""
  #   app_id: ""                       # 可省：自动从包名检测

  # xiaomi:
  #   email: ""                        # 小米开发者账号邮箱
  #   private_key: ""                  # 小米 API private key（上传 SDK 称 password）
  #   cert: ""                         # 可省：默认内置小米公开证书
  #   cert_file: ""

  # oppo:
  #   client_id: ""
  #   client_secret: ""

  # vivo:
  #   access_key: ""
  #   access_secret: ""

  # tencent:
  #   user_id: ""                      # 腾讯开发者 userId
  #   access_secret: ""                # 账户管理 → API 发布接口 → 申请开通
  #   app_id: ""                       # 可省：单包 fallback，多包用 app_id_map
  #   # app_id_map: '{"com.foo":"111","com.bar":"222"}'
  #   package_name: ""                 # 可省：自动从 APK 检测

  # honor:
  #   client_id: ""
  #   client_secret: ""
  #   app_id: ""                       # 可省：自动从包名检测

  # --- 国际商店 ---

  # googleplay:
  #   json_key_file: ""                # Service Account JSON 文件路径
  #   package_name: ""                 # 必须显式填
  #   track: production                # production / beta / alpha / internal

  # samsung:
  #   service_account_id: ""
  #   private_key: ""                  # PEM 格式
  #   content_id: ""                   # Galaxy Store 应用的 content_id
```

| 商店 | 密钥获取入口 | 必填字段 |
|---|---|---|
| 蒲公英 | <https://www.pgyer.com/account/api> | `api_key` |
| 华为 AppGallery | <https://developer.huawei.com/> → 管理中心 → API Key | `service_account`（推荐）或 `client_id` + `client_secret` |
| 小米 | <https://dev.mi.com/xiaomihyperos/> → API 服务 | `email` + `private_key` |
| OPPO | <https://open.oppomobile.com/> → 管理中心 → 证书管理 | `client_id` + `client_secret` |
| vivo | <https://dev.vivo.com.cn/> → API 接入 | `access_key` + `access_secret` |
| 腾讯应用宝 | <https://open.qq.com/> → 账户管理 → API 发布接口 | `user_id` + `access_secret` |
| 荣耀 | <https://developer.honor.com/> → API 管理 | `client_id` + `client_secret` |

> ⚠️ `apkgo.yaml` 包含密钥，不要提交到公开仓库。如果不想写文件，也可以改用环境变量（`APKGO_<STORE>_<FIELD>`），apkgo 会自动读取。

### 三、打包 & 上传

```powershell
# 1. 打包（你自己来）
cd example
flutter build apk --release

# 2. 一键上传到 apkgo.yaml 里所有配置好的商店
.\scripts\upload.ps1 -Notes "测试"

# 只传指定商店
.\scripts\upload.ps1 -Store pgyer -Notes "内测专用"
.\scripts\upload.ps1 -Store pgyer,huawei -Notes "内测专用"

# 用文件传入多行更新说明
.\scripts\upload.ps1 -NotesFile CHANGELOG.md

# 预检查（不上传，只验证密钥配置apkgo.yaml是否正确）
.\scripts\upload.ps1 -DryRun
```

脚本会自动在 `build/app/outputs/flutter-apk/` 下找最新的 `*-release.apk`，也可以用 `-ApkPath` 手动指定。

### 其他命令

```powershell
# 查看 apkgo 支持的所有商店及字段说明
apkgo stores

# 查看上传历史
apkgo history

# 查看当前 apkgo 版本
apkgo version

# 更多命令去apkgo仓库看
```

### 零：准备 apkgo（一次性前置）

1. 从 <https://github.com/KevinGong2013/apkgo/releases> 下载 **v3.x**（别下旧版 v1.x 或 vdev），Windows 如果电脑是 64 位，选 `apkgo_Windows_x86_64.zip`
2. 解压到固定目录，例如 `E:\app\apkgo\apkgo_Windows_x86_64\`
3. 把这个目录加到 Windows **用户环境变量 `PATH`**（设置 → 系统 → 关于 → 高级系统设置 → 环境变量 → 用户变量 → Path → 新增）
4. **重启终端**，验证：

```powershell
apkgo version
# 输出包含 "version": "3.x.x" 即为成功
```

> 💡 兜底：不想改 PATH？脚本也支持 `-ApkgoPath "E:\...\apkgo.exe"` 临时指定，或在 `example/` 下创建 `.apkgo.path`（无扩展名）写一行 apkgo.exe 完整路径即可（已在 `.gitignore` 里，不提交）。