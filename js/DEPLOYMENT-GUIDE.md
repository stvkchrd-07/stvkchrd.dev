# Deployment Guide - stvkchrd.dev

## 🏠 **Local Development Setup**

### **1. Clone and Setup**
```bash
git clone https://github.com/your-username/stvkchrd.dev.git
cd stvkchrd.dev
```

### **2. Create Local Config**
Copy the template and add your Supabase credentials:
```bash
cp js/config.template.js js/config.local.js
```

Edit `js/config.local.js` with your actual credentials:
```javascript
window.env = {
    SUPABASE_URL: 'https://your-project.supabase.co',
    SUPABASE_ANON_KEY: 'your-actual-anon-key'
};
```

### **3. Run Locally**
```bash
# Python 3
python -m http.server 8000

# Node.js
npx serve .

# PHP
php -S localhost:8000
```

Visit: `http://localhost:8000`

## 🌐 **Netlify Deployment**

### **1. Build Settings**
```
Build command: [leave EMPTY]
Publish directory: /
Base directory: [leave EMPTY]
```

### **2. Environment Variables**
In Netlify dashboard → Site settings → Environment variables:

**Add these variables:**
- **Key:** `SUPABASE_URL`
- **Value:** `https://nxhoyxvuyehqnnrqhyom.supabase.co`

- **Key:** `SUPABASE_ANON_KEY`  
- **Value:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54aG95eHZ1eWVocW9tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyMDg2OTEsImV4cCI6MjA3MDc4NDY5MX0.pRUwKmZOxBOQCWdJLJLPgIP_YDkXp5iMPUBN2RpHb5I`

### **3. Deploy**
1. Connect your GitHub repository to Netlify
2. Netlify will auto-deploy on every push
3. Or manually trigger deploy from dashboard

## 🔐 **Security Features**

### **Local Development**
- ✅ **Real Supabase connection** via `config.local.js`
- ✅ **Full functionality** for testing
- ✅ **Credentials never committed** to Git

### **Production (Netlify)**
- ✅ **Environment variables** keep credentials secure
- ✅ **No credentials in browser code**
- ✅ **Easy to rotate keys** without code changes

## 📁 **File Structure**
```
stvkchrd.dev/
├── index.html          # Main portfolio page
├── blog.html           # Blog listing page
├── admin.html          # Admin panel
├── js/
│   ├── config.template.js  # Template (safe to commit)
│   ├── config.local.js     # Local dev (gitignored)
│   ├── config.js           # Production (gitignored)
│   ├── main.js             # Main functionality
│   ├── blog.js             # Blog functionality
│   └── admin.js            # Admin functionality
├── css/
│   └── style.css           # Main stylesheet
└── logo2.png               # Website logo
```

## 🚀 **Deployment Checklist**

### **Before Deploying:**
- [ ] `js/config.local.js` exists with real credentials
- [ ] `js/config.js` is properly configured for production
- [ ] All files are committed to GitHub
- [ ] Netlify environment variables are set

### **After Deploying:**
- [ ] Site loads without errors
- [ ] Projects display from Supabase
- [ ] Blog posts load correctly
- [ ] Admin panel functions properly
- [ ] Theme toggle works
- [ ] Three.js background animates

## 🔧 **Troubleshooting**

### **Site Not Loading:**
- Check Netlify build logs
- Verify environment variables are set
- Ensure no build command is specified

### **Supabase Connection Fails:**
- Verify credentials in environment variables
- Check Supabase project is active
- Ensure database tables exist

### **Local Development Issues:**
- Check `js/config.local.js` exists and has correct credentials
- Verify Supabase project is accessible
- Check browser console for errors

## 📞 **Support**

If you encounter issues:
1. Check browser console for error messages
2. Verify Netlify build logs
3. Ensure all environment variables are set correctly
4. Test locally first before deploying

---

**Remember:** Never commit `js/config.local.js` or `js/config.js` to Git!
