const resources = {
  competitions: { label: 'Competitions', icon: '◉', description: 'Competition seasons, formats and date ranges.', fields: [['name','text','Competition name',true],['season','text','Season'],['format','text','Format'],['starts_on','date','Start date'],['ends_on','date','End date'],['source','text','Data source'],['metadata','json','Metadata'],['published','bool','Published']] },
  matches: { label: 'Matches', icon: '◷', description: 'Fixtures, scores, status and matchday details.', fields: [['competition_id','text','Competition ID'],['home_team_id','text','Home team ID'],['away_team_id','text','Away team ID'],['venue_id','text','Venue ID'],['kickoff_at','datetime','Kick-off'],['status','select','Status',true,['scheduled','live','finished','postponed','cancelled']],['home_score','number','Home score'],['away_score','number','Away score'],['halftime_home_score','number','Half-time home score'],['halftime_away_score','number','Half-time away score'],['stage','text','Stage'],['group_code','text','Group'],['source','text','Data source'],['last_updated','datetime','Last updated'],['published','bool','Published']] },
  teams: { label: 'Teams', icon: '♧', description: 'National team profiles and crests.', fields: [['competition_id','text','Competition ID'],['name','text','Team name',true],['short_name','text','Short name'],['region','text','Region'],['country_code','text','Country code'],['coach','text','Coach'],['crest_url','url','Crest image URL'],['source','text','Data source'],['published','bool','Published']] },
  players: { label: 'Players', icon: '♟', description: 'Player profiles, squad numbers and statistics.', fields: [['team_id','text','Team ID'],['competition_id','text','Competition ID'],['name','text','Player name',true],['position','text','Position'],['shirt_number','number','Shirt number'],['date_of_birth','date','Date of birth'],['club','text','Club'],['caps','number','National team caps'],['photo_url','url','Player photo URL'],['statistics','json','Statistics'],['source','text','Data source'],['published','bool','Published']] },
  standings: { label: 'Standings', icon: '▤', description: 'Published group tables and points.', fields: [['competition_id','text','Competition ID',true],['group_code','text','Group',true],['team_id','text','Team ID',true],['position','number','Position',true],['played','number','Played'],['won','number','Won'],['drawn','number','Drawn'],['lost','number','Lost'],['goals_for','number','Goals for'],['goals_against','number','Goals against'],['goal_difference','number','Goal difference'],['points','number','Points'],['source','text','Data source'],['published','bool','Published']] },
  venues: { label: 'Venues', icon: '⌂', description: 'Stadium details, location and access information.', fields: [['name','text','Venue name',true],['city','text','City'],['country','text','Country'],['capacity','number','Capacity'],['latitude','number','Latitude'],['longitude','number','Longitude'],['address','text','Address'],['accessibility','textarea','Accessibility'],['transport','textarea','Transport'],['source','text','Data source'],['published','bool','Published']] },
  news: { label: 'News & updates', icon: '▧', description: 'Editorial articles shown in the fan app.', fields: [['title','text','Title',true],['category','text','Category'],['summary','textarea','Summary'],['body','textarea','Article body'],['author','text','Author'],['source','text','Publisher / source'],['source_url','url','Source link'],['image_url','url','Image URL'],['image_rights','text','Image rights / licence'],['region','text','Region'],['published_at','datetime','Publication date'],['published','bool','Published']] },
  events: { label: 'Fan events', icon: '▦', description: 'Host-city events and fan activities.', fields: [['title','text','Event title',true],['description','textarea','Description'],['city','text','City'],['region','text','Region'],['starts_at','datetime','Starts at'],['ends_at','datetime','Ends at'],['venue_name','text','Venue'],['booking_url','url','Booking link'],['organizer','text','Organizer'],['source','text','Data source'],['published','bool','Published']] },
  media: { label: 'Media library', icon: '▷', description: 'Images and video with rights information.', fields: [['team_id','text','Team ID'],['title','text','Title',true],['description','textarea','Description'],['media_type','select','Type',true,['image','video','audio']],['image_url','url','Image URL'],['playback_url','url','Playback URL'],['language','text','Language'],['captions_url','url','Captions URL'],['rights_territory','text','Rights territory'],['rights_ends_at','datetime','Rights end date'],['source','text','Data source'],['published','bool','Published']] },
  'match-events': { label: 'Match events', icon: '⌁', description: 'Goals, cards, substitutions and other timeline events.', fields: [['match_id','text','Match ID',true],['team_id','text','Team ID'],['player_id','text','Player ID'],['event_type','text','Event type',true],['minute','number','Minute'],['added_time','number','Added time'],['detail','textarea','Details'],['published','bool','Published']] },
  lineups: { label: 'Line-ups', icon: '☷', description: 'Starting eleven and substitute player records.', fields: [['match_id','text','Match ID',true],['team_id','text','Team ID',true],['player_id','text','Player ID',true],['position','text','Position'],['shirt_number','number','Shirt number'],['is_starting','bool','Starting player'],['published','bool','Published']] },
  'match-statistics': { label: 'Match statistics', icon: '◫', description: 'Team comparison values for a match.', fields: [['match_id','text','Match ID',true],['statistic','text','Statistic (e.g. possession)',true],['home_value','number','Home value'],['away_value','number','Away value'],['published','bool','Published']] },
  qualifiers: { label: 'Qualifiers', icon: '◇', description: 'AFCON PAMOJA qualifying facts, dates and groups.', fields: [['id','text','Content key',true],['payload','json','Qualifier content JSON',true],['published','bool','Published']] },
};

const nav = document.querySelector('#navigation');
const content = document.querySelector('#page-content');
const apiPill = document.querySelector('#api-pill');
const connectionLabel = document.querySelector('#connection-label');
const dialog = document.querySelector('#record-dialog');
const form = document.querySelector('#record-form');
const API_DEFAULT = 'http://localhost:8080/api/v1';
let current = 'overview';
let currentRows = [];
let editing = null;
let toastTimer;

const icons = { overview: '⌂' };
function apiBase() { return (localStorage.getItem('afconApiUrl') || API_DEFAULT).replace(/\/+$/, ''); }
function token() { return sessionStorage.getItem('afconDashboardSession') || ''; }
function esc(value) { return String(value ?? '').replace(/[&<>"']/g, (c) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
function toast(message) { const el=document.querySelector('#toast'); el.textContent=message; el.classList.add('show'); clearTimeout(toastTimer); toastTimer=setTimeout(()=>el.classList.remove('show'),2800); }
function setConnected(online, label) { apiPill.classList.toggle('online', online); apiPill.textContent=online?'API connected':'API offline'; connectionLabel.textContent=label || (online?'Connected to API':'Not connected'); document.querySelectorAll('.status-dot').forEach(dot=>dot.classList.toggle('online',online)); }

function renderNav() {
  const items=[['overview','Overview','⌂'],...Object.entries(resources).map(([key,value])=>[key,value.label,value.icon])];
  nav.innerHTML=items.map(([key,label,icon])=>`<button class="nav-link ${current===key?'active':''}" data-page="${esc(key)}"><span class="nav-icon">${icon}</span><span class="nav-text">${esc(label)}</span></button>`).join('');
  nav.querySelectorAll('[data-page]').forEach(button=>button.addEventListener('click',()=>openPage(button.dataset.page)));
}

async function request(path, options={}) {
  if (!token()) throw new Error('Sign in to continue.');
  const response=await fetch(`${apiBase()}${path}`,{...options,headers:{Accept:'application/json','Content-Type':'application/json',Authorization:`Bearer ${token()}`,...options.headers}});
  const body=await response.json().catch(()=>({}));
  if (!response.ok) throw new Error(body.message || body.error || `Request failed (${response.status})`);
  return body.data;
}

async function connect() {
  const base=apiBase().replace(/\/api\/v1$/,'');
  try { const response=await fetch(`${base}/health`); if(!response.ok) throw new Error(); await response.json(); setConnected(true,'API reachable'); document.querySelector('#auth-api-label').textContent='Backend API is reachable'; document.querySelector('#auth-dot').classList.add('online'); return true; }
  catch { setConnected(false,'API unreachable'); document.querySelector('#auth-api-label').textContent='Cannot reach the backend API'; document.querySelector('#auth-dot').classList.remove('online'); return false; }
}

function openPage(page) { current=page; renderNav(); if(page==='settings') return renderSettings(); if(page==='overview') return renderOverview(); return renderResource(page); }
function heading(title,description,action='') { return `<div class="page-head"><div><div class="eyebrow">${current==='overview'?'CONTROL ROOM':'CONTENT MANAGEMENT'}</div><h1>${esc(title)}</h1><p>${esc(description)}</p></div>${action}</div>`; }

async function renderOverview() {
  content.innerHTML=heading('Overview','Manage the data that appears in the AFCON Fan app.')+`<div class="notice"><div><strong>Connect your backend</strong>Manage content with your signed-in dashboard account. The Flutter app remains read-only.</div><button class="button primary" id="connect-now">Configure connection</button></div><div class="grid-cards" id="overview-stats"></div><div class="overview-grid"><div class="panel"><div class="panel-head"><div><h2>Content collections</h2><p>Open a section to add, edit and publish records.</p></div></div><div class="quick-links" id="quick-links"></div></div><div class="panel"><div class="panel-head"><div><h2>Publishing checklist</h2><p>Review before content reaches supporters.</p></div></div><div class="hint">Verify match times, competition IDs and team IDs. Check source attribution and image or video rights before publishing. Only records with <b>Published</b> enabled are returned to the app.</div></div></div>`;
  document.querySelector('#connect-now').onclick=()=>openPage('settings');
  const quick=document.querySelector('#quick-links'); quick.innerHTML=Object.entries(resources).map(([key,r])=>`<button class="quick-link" data-go="${key}"><span>${r.icon} &nbsp; ${esc(r.label)}</span><span>→</span></button>`).join(''); quick.querySelectorAll('[data-go]').forEach(b=>b.onclick=()=>openPage(b.dataset.go));
  const stats=document.querySelector('#overview-stats'); stats.innerHTML=['matches','teams','players','news'].map(key=>`<div class="stat-card"><span>${esc(resources[key].label)}</span><strong>—</strong><small>Published records</small></div>`).join('');
  if(!token()) return;
  await Promise.all(['matches','teams','players','news'].map(async(key,index)=>{try{const rows=await request(`/admin/${key}`);const cards=stats.children;cards[index].querySelector('strong').textContent=rows.filter(row=>row.published).length;}catch(e){if(index===0)toast(e.message);}}));
}

function displayValue(row,key) {
  const value=row[key]; if(key==='published'||key==='is_starting') return `<span class="badge ${value?'published':''}">${value?'Yes':'No'}</span>`;
  if(value && typeof value==='object') return esc(JSON.stringify(value));
  return esc(value ?? '—');
}
function tableColumns(page,rows) {
  const keys=page==='qualifiers'?['id','payload','published']:page==='news'?['title','category','region','source','published_at','published']:page==='matches'?['status','kickoff_at','home_team_id','away_team_id','home_score','away_score','published']:page==='teams'?['name','region','coach','published']:page==='players'?['name','position','shirt_number','club','published']:page==='standings'?['group_code','team_id','position','played','points','published']:page==='venues'?['name','city','country','capacity','published']:page==='events'?['title','city','starts_at','venue_name','published']:page==='media'?['title','media_type','language','rights_territory','published']:page==='lineups'?['match_id','team_id','player_id','position','shirt_number','is_starting','published']:page==='match-events'?['match_id','event_type','minute','team_id','player_id','published']:['match_id','statistic','home_value','away_value','published'];
  return page==='qualifiers'?keys:['id',...keys];
}

async function renderResource(page) {
  const resource=resources[page]; if(!resource) return renderOverview();
  content.innerHTML=heading(resource.label,resource.description,`<button class="button primary" id="add-record">＋ Add ${esc(resource.label.replace(/s$/,''))}</button>`)+`<div class="notice"><div><strong>App publishing</strong>Only published records appear in the fan app. Confirm source and rights before publishing.</div><button class="button secondary" id="refresh-records">↻ Refresh</button></div><div class="panel"><div class="panel-head"><div><h2>${esc(resource.label)} <span class="badge" id="row-count">0</span></h2><p>Manage and publish tournament information.</p></div><div class="table-tools"><input class="search" id="search-records" placeholder="⌕  Search records" aria-label="Search records"></div></div><div class="table-wrap" id="table-container"><div class="empty"><b>Connect to load ${esc(resource.label.toLowerCase())}</b>Sign in and connect to the backend to view records.</div></div></div>`;
  document.querySelector('#add-record').onclick=()=>showRecordForm(page,null);
  document.querySelector('#refresh-records').onclick=()=>loadRecords(page);
  document.querySelector('#search-records').oninput=()=>renderTable(page,currentRows);
  await loadRecords(page);
}

async function loadRecords(page) {
  const table=document.querySelector('#table-container'); if(!table) return;
  try { currentRows=await request(`/admin/${page}`); setConnected(true,'API connected'); document.querySelector('#row-count').textContent=currentRows.length; renderTable(page,currentRows); }
  catch(error) { table.innerHTML=`<div class="empty"><b>Unable to load records</b>${esc(error.message)}<button class="button secondary" onclick="location.reload()">Try again</button></div>`; if(error.message.includes('token'))setConnected(false,'Admin token required'); }
}

function renderTable(page,rows) {
  const query=(document.querySelector('#search-records')?.value||'').toLowerCase();
  const filtered=rows.filter(row=>JSON.stringify(row).toLowerCase().includes(query));
  const table=document.querySelector('#table-container'); if(!table)return;
  if(!filtered.length){table.innerHTML=`<div class="empty"><b>${rows.length?'No matching records':'No records yet'}</b>${rows.length?'Try a different search.':'Create a record to start populating the app.'}</div>`;return;}
  const cols=tableColumns(page,filtered);
  table.innerHTML=`<table><thead><tr>${cols.map(key=>`<th>${esc(key.replaceAll('_',' ').toUpperCase())}</th>`).join('')}<th>ACTIONS</th></tr></thead><tbody>${filtered.map(row=>`<tr>${cols.map(key=>`<td>${displayValue(row,key)}</td>`).join('')}<td><div class="row-actions"><button class="text-button" data-edit="${esc(row.id)}">Edit</button><button class="text-button danger" data-delete="${esc(row.id)}">Delete</button></div></td></tr>`).join('')}</tbody></table>`;
  table.querySelectorAll('[data-edit]').forEach(button=>button.onclick=()=>showRecordForm(page,rows.find(row=>String(row.id)===button.dataset.edit)));
  table.querySelectorAll('[data-delete]').forEach(button=>button.onclick=()=>deleteRecord(page,button.dataset.delete));
}

function showRecordForm(page,row) {
  editing=row; const resource=resources[page]; document.querySelector('#dialog-resource').textContent=resource.label.toUpperCase(); document.querySelector('#dialog-title').textContent=row?'Edit record':'Add record';
  const fields=document.querySelector('#form-fields');
  fields.innerHTML=resource.fields.map(([key,type,label,required,options])=>{
    const value=row?.[key]; const full=type==='textarea'||type==='json'?' full':'';
    if(type==='bool') return `<div class="field"><label for="f-${key}">${esc(label)}</label><select id="f-${key}" name="${key}"><option value="false" ${value===false?'selected':''}>Draft / No</option><option value="true" ${value===true?'selected':''}>Published / Yes</option></select></div>`;
    if(type==='select') return `<div class="field"><label for="f-${key}">${esc(label)}</label><select id="f-${key}" name="${key}" ${required?'required':''}><option value="">Choose…</option>${options.map(o=>`<option ${value===o?'selected':''}>${esc(o)}</option>`).join('')}</select></div>`;
    const inputType=type==='datetime'?'datetime-local':type==='json'?'textarea':type==='textarea'?'textarea':type==='number'?'number':type==='date'?'date':type==='url'?'url':'text';
    let formatted=value??''; if(type==='json'&&value!==undefined)formatted=JSON.stringify(value,null,2); if(type==='datetime'&&value)formatted=String(value).slice(0,16);
    const tag=inputType==='textarea'?`<textarea id="f-${key}" name="${key}" ${required?'required':''} ${type==='json'?'spellcheck="false"':''}>${esc(formatted)}</textarea>`:`<input id="f-${key}" name="${key}" type="${inputType}" value="${esc(formatted)}" ${required?'required':''} ${type==='number'?'step="any"':''}>`;
    return `<div class="field${full}"><label for="f-${key}">${esc(label)}${required?' *':''}</label>${tag}${key.endsWith('_id')?'<span class="help">Use the existing record UUID.</span>':''}</div>`;
  }).join('');
  form.onsubmit=async(event)=>{event.preventDefault();const button=document.querySelector('#save-record');button.disabled=true;try{const payload={};for(const [key,type] of resource.fields.map(f=>[f[0],f[1]])){const el=form.elements.namedItem(key);if(!el)continue;let v=el.value;if(v==='')continue;if(type==='bool')v=v==='true';if(type==='number')v=Number(v);if(type==='json'){try{v=JSON.parse(v);}catch{throw new Error(`${key} must contain valid JSON.`);}}payload[key]=v;}
      const path=`/admin/${page}${row?`/${encodeURIComponent(row.id)}`:''}`;await request(path,{method:row?'PATCH':'POST',body:JSON.stringify(payload)});dialog.close();toast(row?'Record updated':'Record added');await loadRecords(page);
    }catch(error){toast(error.message);}finally{button.disabled=false;}};
  dialog.showModal();
}

async function deleteRecord(page,id) { if(!confirm('Delete this record? This cannot be undone.'))return;try{await request(`/admin/${page}/${encodeURIComponent(id)}`,{method:'DELETE'});toast('Record deleted');await loadRecords(page);}catch(error){toast(error.message);} }

function renderSettings() {
  content.innerHTML=heading('Connection settings','Connect this dashboard to the AFCON Fan API.')+`<div class="panel settings-card"><h2>Backend API connection</h2><p>Set the API base URL used by this browser. Dashboard access uses your signed-in account. The Flutter app uses public read-only API routes and never receives your dashboard session.</p><div class="field"><label for="api-url">API base URL</label><input id="api-url" value="${esc(apiBase())}" placeholder="http://localhost:8080/api/v1"><span class="help">For example, http://localhost:8080/api/v1</span></div><div class="row-actions"><button class="button primary" id="save-connection">Save and reconnect</button></div></div>`;
  document.querySelector('#save-connection').onclick=async()=>{const url=document.querySelector('#api-url').value.trim().replace(/\/+$/,'');if(!/^https?:\/\//i.test(url)){toast('Enter a valid API URL beginning with http:// or https://');return;}localStorage.setItem('afconApiUrl',url);const online=await connect();if(online){try{await request('/auth/me');toast('Backend connection is ready');openPage('overview');}catch(e){toast(e.message);}}else toast('API is unreachable. Start the backend and check its allowed browser origins.');};
}

document.querySelector('#settings-button').onclick=()=>openPage('settings');
document.querySelector('#logout-button').onclick=async()=>{
  try{await request('/auth/logout',{method:'POST'});}catch{}
  sessionStorage.removeItem('afconDashboardSession');
  document.querySelector('#dashboard-shell').hidden=true;
  showAuth('login',false);
};
document.querySelector('#record-form').addEventListener('click',event=>{if(event.target===dialog)dialog.close();});

let registrationOpen=false;
function showAuth(mode='login',canRegister=registrationOpen,message='') {
  registrationOpen=canRegister;
  document.querySelector('#dashboard-shell').hidden=true;
  document.querySelector('#auth-screen').hidden=false;
  const register=mode==='register'&&canRegister;
  document.querySelector('#auth-title').textContent=register?'Create owner account':'Welcome back';
  document.querySelector('#auth-eyebrow').textContent=register?'FIRST-TIME SETUP':'SECURE DASHBOARD ACCESS';
  document.querySelector('#auth-copy').textContent=register?'Set up the owner account for this AFCON Fan dashboard. Registration closes after the first account is created.':'Sign in to manage AFCON Fan app content.';
  document.querySelector('#name-field').hidden=!register;
  document.querySelector('#auth-name').required=register;
  document.querySelector('#auth-password').autocomplete=register?'new-password':'current-password';
  document.querySelector('#auth-submit').textContent=register?'Create account':'Sign in';
  document.querySelector('#auth-switch').innerHTML=canRegister
    ? register?'Already have an account? <button type="button" id="switch-auth">Sign in</button>':'First time here? <button type="button" id="switch-auth">Create the owner account</button>'
    : 'Dashboard registration is closed. Sign in with the owner account.';
  document.querySelector('#switch-auth')?.addEventListener('click',()=>showAuth(register?'login':'register',canRegister));
  const error=document.querySelector('#auth-error');error.textContent=message;error.hidden=!message;
}

async function authRequest(path,payload) {
  let response;
  try {
    response=await fetch(`${apiBase()}${path}`,{method:'POST',headers:{Accept:'application/json','Content-Type':'application/json'},body:JSON.stringify(payload)});
  } catch {
    throw new Error(`Could not reach ${apiBase()}. Start the backend and allow this dashboard origin in ALLOWED_ORIGINS.`);
  }
  const body=await response.json().catch(()=>({}));
  if(!response.ok)throw new Error(body.message||body.error||`Request failed (${response.status})`);
  return body.data;
}

async function enterDashboard(user) {
  document.querySelector('#auth-screen').hidden=true;
  document.querySelector('#dashboard-shell').hidden=false;
  const initials=(user.display_name||user.email||'AF').split(/[\s@]+/).filter(Boolean).slice(0,2).map(part=>part[0].toUpperCase()).join('');
  document.querySelector('#user-avatar').textContent=initials||'AF';
  await connect();
  renderNav();
  openPage('overview');
}

document.querySelector('#auth-form').addEventListener('submit',async event=>{
  event.preventDefault();
  const button=document.querySelector('#auth-submit');button.disabled=true;
  const register=!document.querySelector('#name-field').hidden;
  try {
    const payload={email:document.querySelector('#auth-email').value.trim(),password:document.querySelector('#auth-password').value};
    if(register)payload.name=document.querySelector('#auth-name').value.trim();
    const result=await authRequest(register?'/auth/register':'/auth/login',payload);
    sessionStorage.setItem('afconDashboardSession',result.token);
    registrationOpen=false;
    await enterDashboard(result.user);
  } catch(error) {
    const message=error.message;
    const status=await fetch(`${apiBase()}/auth/status`).then(r=>r.ok?r.json():null).catch(()=>null);
    const canRegister=Boolean(status?.data?.registrationOpen);
    showAuth(register&&canRegister?'register':'login',canRegister,message);
  } finally {button.disabled=false;}
});

async function boot() {
  renderNav();
  await connect();
  const savedToken=token();
  if(savedToken) {
    try {
      const response=await fetch(`${apiBase()}/auth/me`,{headers:{Accept:'application/json',Authorization:`Bearer ${savedToken}`}});
      const body=await response.json();
      if(response.ok&&body.data)return enterDashboard(body.data);
      sessionStorage.removeItem('afconDashboardSession');
    } catch {}
  }
  try {
    const response=await fetch(`${apiBase()}/auth/status`);
    const body=await response.json();
    if(!response.ok)throw new Error(body.message||body.error||'Could not check dashboard registration.');
    showAuth(body.data?.registrationOpen?'register':'login',Boolean(body.data?.registrationOpen));
  } catch(error) {
    showAuth('login',false,`The dashboard API at ${apiBase()} is not ready. Start the backend, apply all database migrations, and allow http://localhost:3000 in ALLOWED_ORIGINS. Details: ${error.message||'API connection failed.'}`);
  }
}

const apiDialog=document.querySelector('#api-dialog');
document.querySelector('#auth-api-settings').onclick=()=>{document.querySelector('#auth-api-url').value=apiBase();apiDialog.showModal();};
document.querySelector('#save-api-url').onclick=event=>{
  event.preventDefault();
  const url=document.querySelector('#auth-api-url').value.trim().replace(/\/+$/,'');
  if(!/^https?:\/\//i.test(url)){toast('Enter a valid API URL beginning with http:// or https://');return;}
  localStorage.setItem('afconApiUrl',url);
  apiDialog.close();
  boot();
};
boot();
