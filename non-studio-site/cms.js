// Public-site content loader: applies photo/text overrides saved from admin.html.
(function () {
  var CK = 'non_cms_v1';
  var map = {};
  try { map = JSON.parse(localStorage.getItem(CK) || '{}') || {}; } catch (e) {}
  window.NON_CMS = map;

  function apply() {
    var m = window.NON_CMS || {};
    document.querySelectorAll('image-slot[id]').forEach(function (el) {
      var v = m['img:' + el.id];
      if (v && el.getAttribute('src') !== v) el.setAttribute('src', v);
      var vw = m['view:' + el.id];
      if (vw && el.getAttribute('view') !== vw) el.setAttribute('view', vw);
      if (/^cat\d+-\d+$/.test(el.id) && el.parentElement) {
        el.parentElement.style.display = (v || el.getAttribute('src')) ? '' : 'none';
      }
    });
    document.querySelectorAll('[data-cms]').forEach(function (el) {
      var v = m['txt:' + el.getAttribute('data-cms')];
      if (v == null || v === '') return;
      var tn = el.firstChild;
      if (el.childNodes.length === 1 && tn.nodeType === 3) { if (tn.nodeValue !== v) tn.nodeValue = v; }
      else if (el.textContent !== v) el.textContent = v;
      el.style.whiteSpace = v.indexOf('\n') >= 0 ? 'pre-line' : '';
    });
    document.querySelectorAll('[data-cms-href]').forEach(function (el) {
      var v = m['url:' + el.getAttribute('data-cms-href')];
      if (v && el.getAttribute('href') !== v) el.setAttribute('href', v);
    });
  }

  var queued = false;
  function schedule() { if (queued) return; queued = true; requestAnimationFrame(function () { queued = false; apply(); }); }
  new MutationObserver(schedule).observe(document.documentElement, { childList: true, subtree: true });
  document.addEventListener('DOMContentLoaded', schedule);
  schedule();

  var cfg = window.NON_CONFIG || {};
  var url = cfg.SUPABASE_URL, key = cfg.SUPABASE_ANON_KEY;
  if (!url || !key || url.indexOf('YOUR-') >= 0) return;
  var headers = { apikey: key };
  if (key.indexOf('sb_') !== 0) headers.Authorization = 'Bearer ' + key;
  fetch(url.replace(/\/$/, '') + '/rest/v1/site_content?select=key,value', { headers: headers })
    .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function (rows) {
      var next = {};
      rows.forEach(function (r) { next[r.key] = r.value; });
      window.NON_CMS = next;
      try { localStorage.setItem(CK, JSON.stringify(next)); } catch (e) {}
      apply();
      window.dispatchEvent(new Event('cms:ready'));
    })
    .catch(function () {});
})();
