# Deploying NON STUDIO: GitHub, Cloudflare Pages, and Supabase

- **GitHub** stores the code.
- **Cloudflare Pages** hosts the site and redeploys it every time you push.
- **Supabase** stores booking inquiries from the contact form.

## Folder structure

```
index.html            Home page
about.html            About page
admin.html            Admin console (login required)
config.js             Your Supabase URL and key (edit this)
cms.js                Loads your edits onto the site
support.js            Page runtime (required)
image-slot.js         Image component (required)
images/               Portfolio photos
assets/               Favicon, touch icon, stamp
supabase/schema.sql   Database setup (run once)
```

---

## 1. Supabase: database, photo storage, admin login

1. Create a project at https://supabase.com/dashboard by clicking **New project**. Pick the West US region.
2. Open `supabase/schema.sql`. On the **last line**, replace `you@example.com` with the email you will log in with.
3. In Supabase, go to **SQL Editor → New query**. Paste the **entire contents** of the file (not the filename) and click **Run**. You should see "Success. No rows returned."
   This creates:
   - `inquiries`: booking form submissions
   - `site_content`: your edited text and photo links
   - `admins`: emails allowed to use the admin
   - Storage bucket `site`: uploaded photos
4. **Create your admin login.** Go to **Authentication → Users → Add user → Create new user**. Enter the same email and a strong password, and tick **Auto Confirm User**.
5. **Turn off public sign-ups.** Go to **Authentication → Sign In / Providers** and switch **Allow new users to sign up** off.
6. Copy your keys:
   - **Project Settings → API Keys**: the **Publishable key** (`sb_publishable_...`)
   - **Project Settings → Data API**: the **Project URL** (`https://xxxx.supabase.co`)
7. Paste both into `config.js`:

```js
window.NON_CONFIG = {
  SUPABASE_URL: 'https://xxxx.supabase.co',
  SUPABASE_ANON_KEY: 'sb_publishable_...'
};
```

The publishable key is meant to be public. **Never** put the secret key (`sb_secret_...`) in any file.

To add another admin later, run this in SQL Editor, then create a login for them as in step 4:

```sql
insert into public.admins (email) values ('partner@example.com');
```

---

## 2. GitHub: push the code

1. Create a new repository at https://github.com/new, for example `non-studio-site`. It can be private.
2. Upload the files:

   **Browser:** click **uploading an existing file** and drag in everything *inside* the folder, so that `index.html` sits at the repo root. Then click Commit.

   **Terminal:**
   ```bash
   cd non-studio-site
   git init
   git add .
   git commit -m "Initial site"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/non-studio-site.git
   git push -u origin main
   ```

---

## 3. Cloudflare Pages: deploy

1. Go to https://dash.cloudflare.com, then **Workers & Pages → Create → Pages → Connect to Git**.
2. Authorize GitHub and select the `non-studio-site` repo.
3. Build settings:
   - Framework preset: **None**
   - Build command: *(leave empty)*
   - Build output directory: `/`
4. Click **Save and Deploy**. The site goes live at `non-studio-site.pages.dev`.

From now on, every `git push` to `main` redeploys the site automatically.

### Custom domain

In the Pages project, open **Custom domains → Set up a custom domain** and enter your domain, for example `nonstudio.com`.

- If the domain's DNS is already on Cloudflare, the records are added automatically.
- If not, add the CNAME record Cloudflare shows you at your registrar.

HTTPS is issued automatically.

---

## 4. Test the form

1. Open the live site and fill in the booking form.
2. Click **Send inquiry**. You should see the thank-you message.
3. Check **Supabase → Table Editor → inquiries**. A new row should be there.

If you get an error instead:

- Check that `config.js` has the correct URL and anon key, with no trailing spaces.
- Check that you ran `schema.sql`, which also enables the insert policy.
- Open the browser console (F12). A `401` or `403` error usually means a wrong key or a missing policy.

While `config.js` still contains the placeholder values, the form only shows the thank-you screen and saves nothing.

---

## 5. Using the admin

Go to `https://your-domain/admin` and sign in with the email and password from step 1.

- **Inquiries**: every booking form submission, newest first. Set each one to New, Replied, Booked, or Archived. Click an email address to reply.
- **Photos**: upload or replace any photo on the site, including the slideshow (desktop and mobile), category covers, 12 gallery photos per category, the book spread, and the About portrait. Large photos are resized automatically. Empty gallery frames stay hidden on the site.
- **Text**: edit the headline, paragraphs, contact copy, About name and bio, and the Instagram link. **Reset** restores the original copy.

Changes go live immediately. No redeploy is needed. Visitors see them on their next page load.

You only need to push to GitHub again if you change the code or layout.

## Notes

- Preview locally with `npx serve .` or `python3 -m http.server` inside the folder. Opening `index.html` by double-clicking may not work.
- Filenames are case-sensitive. Keep them lowercase as provided.
