# Satvik Chaturvedi Portfolio Website

A modern, responsive portfolio website built with HTML, CSS, and JavaScript. Features include dark/light theme toggle, Three.js particle background, and dynamic content loading.

## Features

- **Responsive Design**: Works on all device sizes
- **Dark/Light Theme**: Toggle between themes with persistent storage
- **Interactive Background**: Three.js particle animation
- **Dynamic Content**: Projects and blog posts loaded from Supabase database
- **Admin Panel**: Manage projects and blog posts
- **Modern UI**: Brutalist design aesthetic with clean typography

## Setup Instructions

### 1. Local Development

The website is now configured to work locally without Supabase. It will display sample projects and blog posts.

### 2. Production Setup with Supabase

To use your own database:

1. **Create a Supabase project** at [supabase.com](https://supabase.com)
2. **Get your credentials**:
   - Project URL
   - Anon (public) key
3. **Update `js/config.js`**:
   ```javascript
   window.env = {
       SUPABASE_URL: 'https://your-project.supabase.co',
       SUPABASE_ANON_KEY: 'your-actual-anon-key'
   };
   ```

### 3. Database Schema

Create these tables in your Supabase database:

#### Projects Table
```sql
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    description TEXT NOT NULL,
    imageUrl TEXT NOT NULL,
    liveUrl TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### Blog Posts Table
```sql
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    date DATE NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## File Structure

```
stvkchrd.dev/
├── index.html          # Main portfolio page
├── blog.html           # Blog listing page
├── post.html           # Individual blog post page
├── admin.html          # Admin panel for managing content
├── css/
│   ├── style.css       # Main stylesheet
│   └── style.min.css   # Minified stylesheet
├── js/
│   ├── main.js         # Main functionality
│   ├── blog.js         # Blog functionality
│   ├── admin.js        # Admin panel functionality
│   ├── post.js         # Blog post functionality
│   ├── utils.js        # Utility functions
│   └── config.js       # Supabase configuration
├── logo2.png           # Website logo
└── generate-config.sh  # Script to generate config for Vercel
```

## Running the Website

### Local Development
1. Open `index.html` in your web browser
2. Or use a local server:
   ```bash
   # Python 3
   python -m http.server 8000
   
   # Node.js
   npx serve .
   
   # PHP
   php -S localhost:8000
   ```

### Production Deployment
1. Update `js/config.js` with your Supabase credentials
2. Deploy to your hosting provider (Vercel, Netlify, etc.)
3. For Vercel, the `generate-config.sh` script will automatically create the config file

## Customization

### Adding Projects
- Use the admin panel at `/admin.html` (requires Supabase setup)
- Or manually edit the sample data in `js/main.js`

### Adding Blog Posts
- Use the admin panel at `/admin.html` (requires Supabase setup)
- Or manually edit the sample data in `js/blog.js`

### Styling
- Edit `css/style.css` for custom styles
- The website uses Tailwind CSS for utility classes

## Troubleshooting

### Website Not Loading
- Check that all files are in the correct locations
- Ensure `js/config.js` exists
- Check browser console for JavaScript errors

### Projects/Blog Posts Not Showing
- If using Supabase: Check your database connection and credentials
- If local: The website will show sample data automatically

### Admin Panel Not Working
- Ensure Supabase is properly configured
- Check that the `posts` and `projects` tables exist in your database

## Browser Support

- Chrome/Edge: Full support
- Firefox: Full support
- Safari: Full support
- Mobile browsers: Full responsive support

## License

© 2025 Satvik Chaturvedi. All rights reserved.
