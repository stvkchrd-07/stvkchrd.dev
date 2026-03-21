# Production Setup Guide

## Tailwind CSS Production Setup

The website currently uses the Tailwind CSS CDN, which shows a warning in production. To fix this:

### Option 1: Install Tailwind CSS locally (Recommended)

1. **Install Node.js** if you haven't already
2. **Initialize npm** in your project:
   ```bash
   npm init -y
   ```

3. **Install Tailwind CSS**:
   ```bash
   npm install -D tailwindcss
   npx tailwindcss init
   ```

4. **Configure Tailwind** - Update `tailwind.config.js`:
   ```javascript
   /** @type {import('tailwindcss').Config} */
   module.exports = {
     content: ["./*.{html,js}"],
     theme: {
       extend: {},
     },
     plugins: [],
   }
   ```

5. **Build CSS** - Create a build script in `package.json`:
   ```json
   {
     "scripts": {
       "build": "tailwindcss -i ./css/style.css -o ./css/style.min.css --watch"
     }
   }
   ```

6. **Run the build**:
   ```bash
   npm run build
   ```

7. **Update HTML files** to use the local CSS instead of CDN:
   ```html
   <!-- Replace this line in all HTML files -->
   <!-- <script src="https://cdn.tailwindcss.com"></script> -->
   
   <!-- With this -->
   <link rel="stylesheet" href="css/style.min.css">
   ```

### Option 2: Use Tailwind CSS CDN (Quick but not recommended for production)

If you want to keep using the CDN temporarily, the warning won't break functionality.

## Supabase Production Setup

1. **Get your Supabase credentials**:
   - Go to your Supabase project dashboard
   - Copy the Project URL and anon key

2. **Update `js/config.js`**:
   ```javascript
   window.env = {
       SUPABASE_URL: 'https://your-project.supabase.co',
       SUPABASE_ANON_KEY: 'your-actual-anon-key'
   };
   ```

3. **Create database tables**:
   ```sql
   -- Projects table
   CREATE TABLE projects (
       id SERIAL PRIMARY KEY,
       title TEXT NOT NULL,
       subtitle TEXT NOT NULL,
       description TEXT NOT NULL,
       imageUrl TEXT NOT NULL,
       liveUrl TEXT NOT NULL,
       created_at TIMESTAMP DEFAULT NOW()
   );

   -- Blog posts table
   CREATE TABLE posts (
       id SERIAL PRIMARY KEY,
       title TEXT NOT NULL,
       date DATE NOT NULL,
       content TEXT NOT NULL,
       created_at TIMESTAMP DEFAULT NOW()
   );
   ```

## Deployment

### Vercel (Recommended)
1. Push your code to GitHub
2. Connect your repository to Vercel
3. The `generate-config.sh` script will automatically create the config file
4. Set environment variables in Vercel dashboard:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

### Netlify
1. Push your code to GitHub
2. Connect your repository to Netlify
3. Set environment variables in Netlify dashboard
4. Update `js/config.js` manually with your credentials

### Manual Deployment
1. Update `js/config.js` with your Supabase credentials
2. If using local Tailwind, run `npm run build` to generate CSS
3. Upload all files to your hosting provider

## Current Status

✅ **Fixed Issues**:
- Missing config.js file
- Corrupted minified JavaScript files
- Logo filename issues
- Supabase connection errors

✅ **Working Features**:
- Sample projects display
- Sample blog posts
- Theme toggle
- Three.js background
- Responsive design

⚠️ **Production Considerations**:
- Replace Tailwind CDN with local build
- Configure Supabase properly
- Test all functionality before deployment
