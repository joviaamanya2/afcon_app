const resources = {
  competitions: { label: 'Competitions', icon: '◉', description: 'Competition seasons, hosts and dates.', fields: [['name','text','Competition name',true],['slug','text','URL slug',true],['season','text','Season',true],['country','text','Region or host'],['startsAt','datetime','Start date'],['endsAt','datetime','End date'],['published','bool','Published']] },
  matches: { label: 'Matches', icon: '◷', description: 'Fixtures, scores, status and matchday details.', fields: [['competitionId','text','Competition ID',true],['stage','text','Stage'],['groupCode','text','Group'],['homeTeamId','text','Home team ID',true],['awayTeamId','text','Away team ID',true],['venueId','text','Venue ID'],['kickoffAt','datetime','Kick-off',true],['status','select','Status',true,['scheduled','live','half_time','finished','postponed','cancelled']],['homeScore','number','Home score'],['awayScore','number','Away score'],['broadcast','text','Broadcast'],['published','bool','Published']] },
  teams: { label: 'Teams', icon: '♧', description: 'National team profiles and crests.', fields: [['name','text','Team name',true],['shortName','text','Short name'],['countryCode','text','Country code'],['region','text','Region'],['crestUrl','url','Crest image URL'],['coach','text','Coach'],['competitionId','text','Competition ID'],['published','bool','Published']] },
  players: { label: 'Players', icon: '♟', description: 'Player profiles, squad numbers and statistics.', fields: [['teamId','text','Team ID'],['competitionId','text','Competition ID'],['name','text','Player name',true],['position','text','Position'],['shirtNumber','number','Shirt number'],['dateOfBirth','date','Date of birth'],['club','text','Club'],['photoUrl','url','Player photo URL'],['stats','json','Statistics'],['published','bool','Published']] },
  standings: { label: 'Standings', icon: '▤', description: 'Published group tables and points.', fields: [['competitionId','text','Competition ID',true],['groupCode','text','Group',true],['teamId','text','Team ID',true],['position','number','Position',true],['played','number','Played'],['won','number','Won'],['drawn','number','Drawn'],['lost','number','Lost'],['goalsFor','number','Goals for'],['goalsAgainst','number','Goals against'],['goalDifference','number','Goal difference'],['points','number','Points'],['published','bool','Published']] },
  venues: { label: 'Venues', icon: '⌂', description: 'Stadium details, location and access information.', fields: [['name','text','Venue name',true],['city','text','City',true],['country','text','Country'],['address','text','Address'],['latitude','number','Latitude'],['longitude','number','Longitude'],['capacity','number','Capacity'],['accessibilityInfo','textarea','Accessibility'],['transportInfo','textarea','Transport'],['timezone','text','Timezone'],['published','bool','Published']] },
  news: { label: 'News & updates', icon: '▧', description: 'Editorial articles shown in the fan app.', fields: [['title','text','Title',true],['slug','text','URL slug',true],['summary','textarea','Summary'],['body','textarea','Article body'],['author','text','Author'],['category','text','Category'],['region','text','Region'],['imageUrl','url','Image URL'],['imageRights','text','Image rights / licence'],['publishedAt','datetime','Publication date'],['published','bool','Published']] },
  events: { label: 'Fan events', icon: '▦', description: 'Host-city events and fan activities.', fields: [['title','text','Event title',true],['description','textarea','Description'],['city','text','City',true],['region','text','Region'],['venueId','text','Venue ID'],['startsAt','datetime','Starts at',true],['endsAt','datetime','Ends at'],['bookingUrl','url','Booking link'],['organizer','text','Organizer'],['published','bool','Published']] },
  media: { label: 'Media library', icon: '▷', description: 'Images and video with rights information.', fields: [['title','text','Title',true],['description','textarea','Description'],['mediaType','select','Type',true,['image','video','audio']],['url','url','Asset URL',true],['thumbnailUrl','url','Thumbnail URL'],['captions','json','Captions'],['territory','text','Rights territory'],['rightsStart','datetime','Rights start'],['rightsEnd','datetime','Rights end'],['teamId','text','Team ID'],['publishedAt','datetime','Publication date'],['published','bool','Published']] },
  'match-events': { label: 'Match events', icon: '⌁', description: 'Goals, cards, substitutions and other timeline events.', fields: [['matchId','text','Match ID',true],['teamId','text','Team ID'],['playerId','text','Player ID'],['relatedPlayerId','text','Related player ID'],['eventType','select','Event type',true,['goal','own_goal','penalty','yellow_card','red_card','substitution','var','kickoff','half_time','full_time']],['minute','number','Minute',true],['addedTime','number','Added time'],['detail','textarea','Details'],['published','bool','Published']] },
  lineups: { label: 'Line-ups', icon: '☷', description: 'Starting eleven and substitute player records.', fields: [['matchId','text','Match ID',true],['teamId','text','Team ID',true],['playerId','text','Player ID',true],['isStarting','bool','Starting player'],['shirtNumber','number','Shirt number'],['position','text','Position'],['formation','text','Formation'],['published','bool','Published']] },
  'match-statistics': { label: 'Match statistics', icon: '◫', description: 'Team comparison values for a match.', fields: [['matchId','text','Match ID',true],['statistic','text','Statistic (e.g. possession)',true],['homeValue','number','Home value'],['awayValue','number','Away value'],['published','bool','Published']] },
  'community-posts': { label: 'Community posts', icon: '☷', description: 'Review fan posts before they appear in the community feed.', fields: [['status','select','Moderation status',true,['pending','published','hidden','removed']]] },
  'community-comments': { label: 'Community comments', icon: '☏', description: 'Review fan comments before they appear in the community feed.', fields: [['status','select','Moderation status',true,['pending','published','hidden','removed']]] },
  'community-reports': { label: 'Community reports', icon: '⚑', description: 'Review reports submitted by fans.', fields: [['status','select','Review status',true,['open','resolved','dismissed']]] },
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
  content.innerHTML=heading('Overview','Manage the data that appears in the AFCON Fan app.')+`<div class="notice"><div><strong>Connect your backend</strong>Manage tournament data and review fan posts and comments with the shared admin token. Fan accounts use their own sign-in in the Flutter app.</div><button class="button primary" id="connect-now">Configure connection</button></div><div class="grid-cards" id="overview-stats"></div><div class="overview-grid"><div class="panel"><div class="panel-head"><div><h2>Content collections</h2><p>Open a section to add, edit and publish records.</p></div></div><div class="quick-links" id="quick-links"></div></div><div class="panel"><div class="panel-head"><div><h2>Publishing checklist</h2><p>Review before content reaches supporters.</p></div></div><div class="hint">Verify match times, competition IDs and team IDs. Check source attribution and image or video rights before publishing. Only records with <b>Published</b> enabled are returned to the app.</div></div></div>`;
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
function formValue(row,key,type) {
  const databaseKey=key.replace(/[A-Z]/g,letter=>`_${letter.toLowerCase()}`);
  const value=row?.[key] ?? row?.[databaseKey];
  if(value==null) return '';
  if(type==='json') return JSON.stringify(value,null,2);
  if(type==='datetime' && value) {
    const date=new Date(value);
    if(!Number.isNaN(date.getTime())) return new Date(date.getTime()-date.getTimezoneOffset()*60000).toISOString().slice(0,16);
  }
  if(type==='date' && value) return String(value).slice(0,10);
  return value;
}
function tableColumns(page,rows) {
  const keys=page==='community-posts'?['display_name','content','status','created_at','likes_count','comments_count']:page==='community-comments'?['display_name','content','status','created_at']:page==='community-reports'?['target_type','reported_content','reason','reporter_name','status','created_at']:page==='news'?['title','category','region','author','published_at','published']:page==='matches'?['status','kickoff_at','home_team','away_team','home_score','away_score','published']:page==='teams'?['name','region','coach','published']:page==='players'?['name','position','shirt_number','club','published']:page==='standings'?['group_code','team_id','position','played','points','published']:page==='venues'?['name','city','country','capacity','published']:page==='events'?['title','city','starts_at','venue_id','published']:page==='media'?['title','media_type','territory','rights_end','published']:page==='lineups'?['match_id','team_id','player_id','position','shirt_number','is_starting','published']:page==='match-events'?['match_id','event_type','minute','team_id','player_id','published']:['match_id','statistic','home_value','away_value','published'];
  return ['id',...keys];
}

async function renderResource(page) {
  const resource=resources[page]; if(!resource) return renderOverview();
  const canCreate=!page.startsWith('community-');
  content.innerHTML=heading(resource.label,resource.description,canCreate?`<button class="button primary" id="add-record">＋ Add ${esc(resource.label.replace(/s$/,''))}</button>`:'')+`<div class="notice"><div><strong>${canCreate?'App publishing':'Community moderation'}</strong>${canCreate?'Only published records appear in the fan app. Confirm source and rights before publishing.':'Set approved content to published. Hidden or removed content will not appear in the fan app.'}</div><button class="button secondary" id="refresh-records">↻ Refresh</button></div><div class="panel"><div class="panel-head"><div><h2>${esc(resource.label)} <span class="badge" id="row-count">0</span></h2><p>${canCreate?'Manage and publish tournament information.':'Review and update pending fan content.'}</p></div><div class="table-tools"><input class="search" id="search-records" placeholder="⌕  Search records" aria-label="Search records"></div></div><div class="table-wrap" id="table-container"><div class="empty"><b>Connect to load ${esc(resource.label.toLowerCase())}</b>Sign in and connect to the backend to view records.</div></div></div>`;
  if(canCreate)document.querySelector('#add-record').onclick=()=>showRecordForm(page,null);
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
  const canDelete=!page.startsWith('community-');
  table.innerHTML=`<table><thead><tr>${cols.map(key=>`<th>${esc(key.replaceAll('_',' ').toUpperCase())}</th>`).join('')}<th>ACTIONS</th></tr></thead><tbody>${filtered.map(row=>`<tr>${cols.map(key=>`<td>${displayValue(row,key)}</td>`).join('')}<td><div class="row-actions"><button class="text-button" data-edit="${esc(row.id)}">${canDelete?'Edit':'Review'}</button>${canDelete?`<button class="text-button danger" data-delete="${esc(row.id)}">Delete</button>`:''}</div></td></tr>`).join('')}</tbody></table>`;
  table.querySelectorAll('[data-edit]').forEach(button=>button.onclick=()=>showRecordForm(page,rows.find(row=>String(row.id)===button.dataset.edit)));
  table.querySelectorAll('[data-delete]').forEach(button=>button.onclick=()=>deleteRecord(page,button.dataset.delete));
}

function showRecordForm(page,row) {
  editing=row; const resource=resources[page]; document.querySelector('#dialog-resource').textContent=resource.label.toUpperCase(); document.querySelector('#dialog-title').textContent=row?'Edit record':'Add record';
  const fields=document.querySelector('#form-fields');
  fields.innerHTML=resource.fields.map(([key,type,label,required,options])=>{
    const value=formValue(row,key,type); const full=type==='textarea'||type==='json'?' full':'';
    if(type==='bool') return `<div class="field"><label for="f-${key}">${esc(label)}</label><select id="f-${key}" name="${key}"><option value="false" ${value===false?'selected':''}>Draft / No</option><option value="true" ${value===true?'selected':''}>Published / Yes</option></select></div>`;
    if(type==='select') return `<div class="field"><label for="f-${key}">${esc(label)}</label><select id="f-${key}" name="${key}" ${required?'required':''}><option value="">Choose…</option>${options.map(o=>`<option ${value===o?'selected':''}>${esc(o)}</option>`).join('')}</select></div>`;
    const inputType=type==='datetime'?'datetime-local':type==='json'?'textarea':type==='textarea'?'textarea':type==='number'?'number':type==='date'?'date':type==='url'?'url':'text';
    let formatted=value??'';
    const tag=inputType==='textarea'?`<textarea id="f-${key}" name="${key}" ${required?'required':''} ${type==='json'?'spellcheck="false"':''}>${esc(formatted)}</textarea>`:`<input id="f-${key}" name="${key}" type="${inputType}" value="${esc(formatted)}" ${required?'required':''} ${type==='number'?'step="any"':''}>`;
    return `<div class="field${full}"><label for="f-${key}">${esc(label)}${required?' *':''}</label>${tag}${key.endsWith('_id')?'<span class="help">Use the existing record UUID.</span>':''}</div>`;
  }).join('');
  form.onsubmit=async(event)=>{event.preventDefault();const button=document.querySelector('#save-record');button.disabled=true;try{const payload={};for(const [key,type] of resource.fields.map(f=>[f[0],f[1]])){const el=form.elements.namedItem(key);if(!el)continue;let v=el.value;if(type==='bool')v=v==='true';else if(v===''){continue;}else if(type==='number')v=Number(v);else if(type==='datetime')v=new Date(v).toISOString();else if(type==='json'){try{v=JSON.parse(v);}catch{throw new Error(`${key} must contain valid JSON.`);}}payload[key]=v;}
      const path=`/admin/${page}${row?`/${encodeURIComponent(row.id)}`:''}`;await request(path,{method:row?'PATCH':'POST',body:JSON.stringify(payload)});dialog.close();toast(row?'Record updated':'Record added');await loadRecords(page);
    }catch(error){toast(error.message);}finally{button.disabled=false;}};
  dialog.showModal();
}

async function deleteRecord(page,id) { if(!confirm('Delete this record? This cannot be undone.'))return;try{await request(`/admin/${page}/${encodeURIComponent(id)}`,{method:'DELETE'});toast('Record deleted');await loadRecords(page);}catch(error){toast(error.message);} }

function renderSettings() {
  content.innerHTML=heading('Connection settings','Connect this dashboard to the AFCON Fan API.')+`<div class="panel settings-card"><h2>Backend API connection</h2><p>Set the API base URL used by this browser. Admin edits use the shared ADMIN_API_TOKEN. The Flutter app uses public read routes and fan-account tokens for social features.</p><div class="field"><label for="api-url">API base URL</label><input id="api-url" value="${esc(apiBase())}" placeholder="http://localhost:8080/api/v1"><span class="help">For example, http://localhost:8080/api/v1</span></div><div class="row-actions"><button class="button primary" id="save-connection">Save and reconnect</button></div></div>`;
  document.querySelector('#save-connection').onclick=async()=>{const url=document.querySelector('#api-url').value.trim().replace(/\/+$/,'');if(!/^https?:\/\//i.test(url)){toast('Enter a valid API URL beginning with http:// or https://');return;}localStorage.setItem('afconApiUrl',url);const online=await connect();if(online){try{await request('/admin/overview');toast('Backend connection is ready');openPage('overview');}catch(e){toast(e.message);}}else toast('API is unreachable. Start the backend and check its allowed browser origins.');};
}

document.querySelector('#settings-button').onclick=()=>openPage('settings');
document.querySelector('#logout-button').onclick=async()=>{
  sessionStorage.removeItem('afconDashboardSession');
  document.querySelector('#dashboard-shell').hidden=true;
  showAuth();
};
document.querySelector('#record-form').addEventListener('click',event=>{if(event.target===dialog)dialog.close();});

function showAuth(message='') {
  document.querySelector('#dashboard-shell').hidden=true;
  document.querySelector('#auth-screen').hidden=false;
  document.querySelector('#auth-title').textContent='Connect to your backend';
  document.querySelector('#auth-eyebrow').textContent='SECURE DASHBOARD ACCESS';
  document.querySelector('#auth-copy').textContent='Enter the ADMIN_API_TOKEN configured in backend/.env to manage app content.';
  const error=document.querySelector('#auth-error');error.textContent=message;error.hidden=!message;
}

async function enterDashboard() {
  document.querySelector('#auth-screen').hidden=true;
  document.querySelector('#dashboard-shell').hidden=false;
  document.querySelector('#user-avatar').textContent='AD';
  await connect();
  renderNav();
  openPage('overview');
}

document.querySelector('#auth-form').addEventListener('submit',async event=>{
  event.preventDefault();
  const button=document.querySelector('#auth-submit');button.disabled=true;
  try {
    sessionStorage.setItem('afconDashboardSession',document.querySelector('#auth-token').value.trim());
    await request('/admin/overview');
    await enterDashboard();
  } catch(error) {
    sessionStorage.removeItem('afconDashboardSession');
    showAuth(error.message || 'Could not connect to the backend.');
  } finally {button.disabled=false;}
});

async function boot() {
  renderNav();
  await connect();
  if (token()) {
    try {
      await request('/admin/overview');
      await enterDashboard();
      return;
    } catch {
      sessionStorage.removeItem('afconDashboardSession');
    }
  }
  showAuth();
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
