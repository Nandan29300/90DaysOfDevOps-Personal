# Day 03 Summary – What I Learned: Linux Commands

## What I Learned
Today I focused on building a strong foundation in Linux commands that are essential for DevOps and real-world troubleshooting.

## Key Areas Covered
- Process Management → Monitoring and controlling running processes  
- File System → Navigating and managing files efficiently  
- Networking → Diagnosing connectivity and DNS issues  

## Favorite Commands
- `top` → Helps monitor system performance in real-time  
- `grep` → Extremely useful for searching logs  
- `curl` → Great for testing APIs and endpoints  

## Networking Highlight
- Used `ping` to check connectivity  
- Used `dig` to understand DNS resolution  

## Key Takeaway
* Most production issues can be diagnosed using just a few powerful Linux commands.  
* Mastering them improves debugging speed and confidence.

## Next Step
Continue practicing commands in real scenarios and combine them with shell scripting.

---

## Key Things I Understood

- `tail -f` is the go-to command for watching live logs during troubleshooting
- `ss` is the modern replacement for `netstat` — faster and more reliable
- `bg` and `fg` are for managing jobs when your terminal is occupied
- `grep` + `tail` together is a powerful combo: `tail -f app.log | grep "error"`
- `chmod 755` means owner can do everything, others can only read and run
- `find` and `grep` are different — `find` locates files, `grep` searches inside them

## ✅ Notes
- Always use `rm -rf` carefully — it deletes permanently  
- Use `top/htop` during performance issues  
- Use `ping`, `curl`, `dig` for quick network debugging  
