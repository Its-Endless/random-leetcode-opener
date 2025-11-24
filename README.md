# LeetCode Opener

A fast, lightweight LeetCode problem launcher for Windows.  
It opens random or filtered LeetCode problems directly in your browser and keeps track of all problems you've already visited.  
Built using a simple **batch file + PowerShell script** combo.

---

## ⭐ Features

- 🔀 Open a **random** free LeetCode problem  
- 🎯 Filter by **difficulty** → `easy`, `medium`, `hard`  
- 🏷️ Filter by **tag** → `dp`, `tree`, `string`, `graph`, `array`, `sorting`, `greedy`, `backtracking`  
- 📅 Open the **daily challenge**  
- 📚 Open the **LeetCode 75** study plan  
- ⏭️ Open the **next unvisited** free problem using local history  
- 🔢 Open by **problem ID** or by **slug** (e.g., `two-sum`)  
- 📄 Local storage of solved/visited problems (`.leetcode_progress.txt`)  
- 📊 `stats` → View count + sample visited IDs  
- ♻️ `reset` → Clear progress  

---

## 📁 Files in This Project

| File | Description |
|------|-------------|
| `leetcode.bat` | Windows batch launcher |
| `leetcode_helper.ps1` | Core PowerShell logic |
| `.leetcode_progress.txt` | Auto-created history of visited problems |
| `README.md` | Project documentation |

Progress is stored **in the same directory as these files**.

---

## 🧰 Requirements

- Windows  
- PowerShell 5.1+ (comes preinstalled)  
- Internet connection  
- Default browser configured  

---

## 🚀 Installation

1. Download/clone this repository into any folder, e.g.:
```

D:\Leetcode

```
2. Make sure these files are in the same directory:
- `leetcode.bat`
- `leetcode_helper.ps1`
3. (Optional) Add that directory to your system PATH for global use.

---

## 🕹️ Usage

Run from **Command Prompt** (not PowerShell):

### 🔀 Random problem
```

leetcode.bat

```

### 🎯 Difficulty filters
```

leetcode.bat easy
leetcode.bat medium
leetcode.bat hard

```

### 🏷️ Tags
```

leetcode.bat dp
leetcode.bat tree
leetcode.bat string
leetcode.bat graph
leetcode.bat array
leetcode.bat sorting
leetcode.bat greedy
leetcode.bat backtracking

```

### 📅 Daily challenge
```

leetcode.bat daily

```

### 🏆 LeetCode 75
```

leetcode.bat 75

```

### ⏭️ Next unsolved
```

leetcode.bat next

```

### 🔢 By numeric ID
```

leetcode.bat 1

```

### 🔤 By slug
```

leetcode.bat two-sum

```

### 📊 Stats
```

leetcode.bat stats

```

### ♻️ Reset local progress
```

leetcode.bat reset

```

---

## 📂 Progress Storage

The script automatically maintains a file:

```

.leetccode_progress.txt

```

Location:
```

<your project folder>.leetcode_progress.txt

```

Each visited problem ID is appended to this file.

You can:
- Back it up  
- Edit it  
- Delete it (same as `leetcode.bat reset`)  

---

## 🛠️ Troubleshooting

### ❗ Invoke-WebRequest errors  
The script forces TLS 1.2 + adds custom headers to avoid block issues.  
If errors persist, check if https://leetcode.com/api/problems/all/ opens in your browser.

### ❗ Problems not opening  
Ensure your **default browser** is set.

### ❗ Script doesn’t run  
Always run from **Command Prompt**, or add the folder to PATH.

---

## 🤝 Contributing

Open to improvements:
- More tags  
- SQLite progress tracking  
- GUI launcher  
- Multi-platform version  

PRs welcome!

---

## 📜 License

MIT License — free to modify and reuse.

---

## 🎉 Enjoy Practicing!

This tool makes LeetCode problem discovery fast, flexible, and fun.  
Happy coding! 🚀🔥
