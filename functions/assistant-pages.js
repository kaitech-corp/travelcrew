const {randomBytes} = require("node:crypto");
const escape = (v) => String(v).replace(/[&<>"']/g, (c) => ({"&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;"}[c]));
function page(res, title, body, script = "") {
  const nonce = randomBytes(18).toString("base64");
  res.set("Content-Security-Policy", `default-src 'none'; script-src 'nonce-${nonce}' https://www.gstatic.com https://apis.google.com; style-src 'nonce-${nonce}'; connect-src 'self' https://*.googleapis.com https://*.firebaseapp.com https://*.google.com; frame-src https://*.firebaseapp.com https://accounts.google.com https://appleid.apple.com; img-src 'self' https: data:; base-uri 'none'; form-action 'self'; frame-ancestors 'none'`);
  res.type("html").send(`<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${escape(title)} · TravelCrew</title><style nonce="${nonce}">body{font:17px system-ui;background:#f5f7fa;color:#172638;margin:0;padding:32px 16px}main{max-width:480px;margin:8vh auto;background:white;border-radius:20px;padding:32px;box-shadow:0 8px 40px #17263812}h1{font-size:28px}button,a.button{cursor:pointer;border:0;border-radius:10px;background:#176e62;color:white;padding:13px 18px;font:inherit;display:inline-block;text-decoration:none;margin:6px 0}button:disabled{opacity:.5}input{box-sizing:border-box;width:100%;padding:12px;margin:6px 0 14px;border:1px solid #a7b4be;border-radius:8px;font:inherit}.secondary{background:#e9eef2;color:#172638}#error{color:#9d2436;white-space:pre-wrap}.muted{color:#536575;font-size:14px}li{margin:16px 0}#account{overflow-wrap:anywhere}[hidden]{display:none!important}</style></head><body><main><p class="muted">TRAVELCREW</p><h1>${escape(title)}</h1>${body}</main>${script ? `<script type="module" nonce="${nonce}">${script}</script>` : ""}</body></html>`);
}
function accountPage(res, {baseUrl, firebaseConfig, request}) {
  const config = JSON.stringify({baseUrl, firebaseConfig, requestId: request?.id}).replace(/</g, "\\u003c");
  const body = request ? `<p><strong>${escape(request.clientName)}</strong> is asking to create private trips in your TravelCrew account.</p><p class="muted">This connection can add itineraries and expenses you request. It cannot read or edit existing trips, invite people, or publish trips. Access expires after 30 days. You can disconnect it at any time.</p><p class="muted">Return address: ${escape(new URL(request.redirect).origin)}</p>` : "<p>Manage the assistants connected to your TravelCrew account.</p>";
  page(res, request ? "Connect your assistant" : "Connected assistants", `${body}
    <section id="signin"><form id="login"><label for="email">Email</label><input id="email" type="email" autocomplete="username" required><label for="password">Password</label><input id="password" type="password" autocomplete="current-password" required><button type="submit">Sign in</button></form><button id="google" class="secondary">Continue with Google</button> <button id="apple" class="secondary">Continue with Apple</button><p class="muted">Use your existing TravelCrew account. New accounts must first be set up in the app.</p></section>
    <section id="signedin" hidden><p id="account"></p>${request ? "<button id=approve>Allow trip creation</button>" : "<ul id=connections></ul>"}<p><button id="signout" class="secondary">Switch account</button></p></section>
    ${request ? "<button id=deny class=secondary>Cancel</button>" : ""}<p id="error" role="alert"></p>`, `
    import {initializeApp} from 'https://www.gstatic.com/firebasejs/12.19.0/firebase-app.js';
    import {getAuth,setPersistence,inMemoryPersistence,signInWithEmailAndPassword,signInWithPopup,GoogleAuthProvider,OAuthProvider,onAuthStateChanged,signOut} from 'https://www.gstatic.com/firebasejs/12.19.0/firebase-auth.js';
    const config=${config}; const auth=getAuth(initializeApp(config.firebaseConfig)); await setPersistence(auth,inMemoryPersistence);
    const $=id=>document.getElementById(id); const report=e=>{$('error').textContent=e.message||'Please try again.';};
    async function api(path,body,method='POST') {
      const token=auth.currentUser?await auth.currentUser.getIdToken():'';
      const response=await fetch(config.baseUrl+path,{method,headers:{'Content-Type':'application/json',...(token?{Authorization:'Bearer '+token}:{})},...(method==='GET'?{}:{body:JSON.stringify(body)})});
      const result=await response.json(); if(!response.ok)throw new Error(result.error_description||result.message||'Request failed'); return result;
    }
    $('login').onsubmit=async e=>{e.preventDefault();$('error').textContent='';try{await signInWithEmailAndPassword(auth,$('email').value,$('password').value);$('password').value='';}catch(e){report(e);}};
    $('google').onclick=()=>signInWithPopup(auth,new GoogleAuthProvider()).catch(report);
    $('apple').onclick=()=>signInWithPopup(auth,new OAuthProvider('apple.com')).catch(report);
    $('signout').onclick=()=>signOut(auth).catch(report);
    async function loadConnections(){const data=await api('/connections',null,'GET');$('connections').replaceChildren();if(!data.connections.length)$('connections').textContent='No assistants are connected.';for(const connection of data.connections){const li=document.createElement('li');li.append(document.createTextNode(connection.name+' '));const b=document.createElement('button');b.textContent='Disconnect';b.onclick=async()=>{try{await api('/connections/'+connection.id,{},'DELETE');await loadConnections();}catch(e){report(e);}};li.append(b);$('connections').append(li);}}
    onAuthStateChanged(auth,user=>{$('signin').hidden=!!user;$('signedin').hidden=!user;$('account').textContent=user?'Signed in as '+(user.email||user.displayName||'TravelCrew traveler'):'';if(user&&!config.requestId)loadConnections().catch(report);});
    async function consent(approve){const button=$(approve?'approve':'deny');button.disabled=true;try{const result=await api('/oauth/consent',{request_id:config.requestId,approve});window.location.assign(result.redirect);}catch(e){report(e);button.disabled=false;}}
    if(config.requestId){$('approve').onclick=()=>consent(true);$('deny').onclick=()=>consent(false);}
  `);
}
function tripPage(res, id) {
  page(res, "Your trip is ready", `<p>Open TravelCrew to view this trip. Sign in to the account you connected to your assistant.</p><a class="button" href="travelcrew://trips/${escape(id)}">Open in TravelCrew</a><p class="muted">If the app does not open, install or update TravelCrew, then find your trip in My Trips.</p>`);
}
module.exports = {accountPage, tripPage};
