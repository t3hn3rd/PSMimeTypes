# 📄 PSMimeTypes

## 🌍 Overview

**PSMimeTypes** is a PowerShell module that provides functionality for resolving MIME types from file extensions and filenames. It utilizes the [JSHTTP Mime-DB](https://github.com/jshttp/mime-db) for MIME type lookups. By default, the module fetches the database from the internet but also allows importing a local JSON copy for offline usage.

## ✨ Features
- Resolve MIME types from file extensions.
- Extract file extensions from filenames and determine the corresponding MIME type.
- Import a local MIME database for offline lookups.

## 🔧 Installation

To use **PSMimeTypes**, import the module into your PowerShell session:

```powershell
Install-Module "PSMimeTypes"
Import-Module "PSMimeTypes"
```

## 📌 Functions & Usage

### 🏷 Resolve MIME Type from Extension
```powershell
Convert-ExtensionToMimeType -Extension "jpg"
# Output: image/jpeg
'.jpg' | Convert-ExtensionToMimeType
# Output: image/jpeg
```

### 📂 Resolve MIME Type from Filename
```powershell
Convert-FileNameToMimeType -FileName "document.pdf"
# Output: application/pdf
'C:\Users\MyUser\MyDocument\test.pdf' | Convert-FileNameToMimeType
# Output: application/pdf
```

### 📥 Import Local MIME Database
```powershell
Import-MimeDBFromFile -Path "C:\path\to\mime-db.json"
# Output: True (if successful) or False (if failed)
```

## 📦 Dependencies
This module relies on:
- [JSHTTP Mime-DB](https://github.com/jshttp/mime-db), a comprehensive and community-maintained MIME type database.

## 🤝 Contributions
Contributions are welcome! If you'd like to improve this module, feel free to submit a pull request or open an issue.

## 📜 License
This project is licensed under the Apache 2.0 License. See the LICENSE file for details.

## 🎖 Credits
This project makes use of the [JSHTTP Mime-DB](https://github.com/jshttp/mime-db). Special thanks to the maintainers and contributors of the Mime-DB for their work in maintaining an extensive and accurate MIME type database.

## 👨‍💻 Author
**Kieron Morris** (t3hn3rd) - [kjm@kieronmorris.me](mailto:kjm@kieronmorris.me)

