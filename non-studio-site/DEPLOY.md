# Deploying NON STUDIO: GitHub, Cloudflare Pages, and Supabase

- **GitHub** stores the code.
- **Cloudflare Pages** hosts the site and redeploys it every time you push.
- **Supabase** stores booking inquiries from the contact form.

## Folder structure

```
index.html            Home page
about.html            About page
config.js             Your Supabase URL and key (edit this)
support.js            Page runtime (required)
image-slot.js         Image component (required)
images/               Portfolio photos
assets/               Favicon, touch icon, stamp
supabase/schema.sql   Database setup (run once)
```

---

## 1. Supabase: set up the inquiry database

1. Go to https://supabase.com and create a **New project**. Pick a region close to Los Angeles, for example West US.
2. Open **SQL Editor → New query**. Paste the contents of `supabase/schema.sql` and click **Run**.
   This creates an `inquiries` table. Visitors can submit to it but cannot read it.
3. Go to **Project Settings → API** and copy:
   - **Project URL**, for example `https://abcd1234.supabase.co`
   - **anon public** key
4. Open `config.js` and paste them in:

```js
window.NON_CONFIG = {
  SUPABASE_URL: 'https://abcd1234.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOi...'
};
```

The anon key is meant to be public. Row Level Security keeps the table write-only for visitors. **Never** put the `service_role` key in this file.

To view inquiries, go to **Table Editor → inquiries**.

**Optional: email notifications.** Go to **Database → Webhooks → Create a new hook**, choose the `inquiries` table and the `INSERT` event, and send it to a service such as Zapier, Make, or Pipedream. That service can then forward each new inquiry to your email.

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

## Updating the site

- **Photos:** replace a file in `images/` with a new photo that has the **same filename**, then commit and push.
- **Text or layout:** edit the HTML, then commit and push. Cloudflare redeploys in about 30 seconds.

## Notes

- Preview locally with `npx serve .` or `python3 -m http.server` inside the folder. Opening `index.html` by double-clicking may not work.
- Filenames are case-sensitive. Keep them lowercase as provided.
