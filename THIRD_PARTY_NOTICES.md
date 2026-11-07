# 第三方组件声明 (Third-Party Notices)

本项目 (Neko Assistant KSU) 的核心代码基于 MIT 协议开源。在开发与运行过程中，本项目集成或使用了以下优秀的第三方开源组件。我们尊重并感谢原作者的贡献。

关于以下组件的完整开源协议全文，请参阅本项目根目录下的 `LICENSES` 文件夹。

## 1. YADB
- **项目地址**: https://github.com/ysbing/YADB
- **版权声明**: Copyright (c) ysbing
- **开源协议**: GNU Lesser General Public License v3.0 (LGPL-3.0)
- **使用说明**: 
  本模块通过 `app_process` 调用 YADB 提供的独立二进制文件（未修改其源代码），用于实现 Android 系统上的原生文本注入（键盘输入）功能。由于采用的是独立进程调用而非静态链接，符合 LGPL-3.0 协议规范。

## 2. Tesseract OCR
- **项目地址**: https://github.com/tesseract-ocr/tesseract
- **版权声明**: Copyright (c) The Tesseract OCR Project Contributors
- **开源协议**: Apache License 2.0
- **使用说明**: 
  本模块使用了社区为 Android 交叉编译的 Tesseract 静态二进制文件及对应的语言训练数据（如 `chi_sim.traineddata`），用于在设备本地离线执行光学字符识别（OCR）任务。

---

## 前端依赖库说明 (Frontend Libraries)

本项目的 WebUI 界面（`index.html`）在浏览器端加载了以下前端开源库。由于它们通过静态文件引入，这里一并致谢：
- **markdown-it** (MIT License)
- **KaTeX** (MIT License)
- **mermaid** (MIT License)
- **DOMPurify** (Apache License 2.0 / Mozilla Public License 2.0)
- **officeparser** (MIT License)

*(注：前端库的版权信息包含在各自的 `.min.js` 或 `.min.css` 文件头部注释中)*
