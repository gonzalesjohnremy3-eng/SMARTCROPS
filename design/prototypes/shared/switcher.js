(function () {
  var sections = Array.prototype.slice.call(document.querySelectorAll('.variant'));
  if (!sections.length) return;

  var keys = sections.map(function (section) {
    return section.getAttribute('data-variant');
  });
  var names = sections.map(function (section) {
    return section.getAttribute('data-variant-name') || section.getAttribute('data-variant');
  });

  function current() {
    var requested = new URLSearchParams(window.location.search).get('variant');
    var index = keys.indexOf(requested);
    return index < 0 ? 0 : index;
  }

  function render() {
    var index = current();
    sections.forEach(function (section, i) {
      section.classList.toggle('is-active', i === index);
    });
    label.textContent = keys[index] + ' (' + names[index] + ')';
  }

  function go(delta) {
    var next = (current() + delta + keys.length) % keys.length;
    var url = new URL(window.location.href);
    url.searchParams.set('variant', keys[next]);
    window.history.replaceState(null, '', url.toString());
    render();
  }

  var bar = document.createElement('div');
  bar.setAttribute('role', 'navigation');
  bar.setAttribute('aria-label', 'Prototype variant switcher');
  bar.style.cssText =
    'position:fixed;left:50%;bottom:20px;transform:translateX(-50%);display:flex;align-items:center;gap:12px;' +
    'padding:8px 12px;background:#12372A;color:#FFFDF7;border-radius:999px;box-shadow:0 12px 32px rgba(18,55,42,.28);' +
    'font:600 13px/1 "Public Sans",system-ui,sans-serif;z-index:9999;';

  function makeButton(text, delta) {
    var button = document.createElement('button');
    button.textContent = text;
    button.setAttribute('aria-label', delta < 0 ? 'Previous variant' : 'Next variant');
    button.style.cssText =
      'width:32px;height:32px;border-radius:50%;border:1px solid rgba(255,253,247,.35);' +
      'background:transparent;color:#FFFDF7;font-size:16px;line-height:1;';
    button.addEventListener('click', function () { go(delta); });
    return button;
  }

  var label = document.createElement('span');
  label.setAttribute('aria-live', 'polite');
  label.style.minWidth = '190px';
  label.style.textAlign = 'center';

  bar.appendChild(makeButton('‹', -1));
  bar.appendChild(label);
  bar.appendChild(makeButton('›', 1));
  document.body.appendChild(bar);

  document.addEventListener('keydown', function (event) {
    var target = event.target;
    if (target && /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName)) return;
    if (target && target.isContentEditable) return;
    if (event.key === 'ArrowLeft') { go(-1); }
    if (event.key === 'ArrowRight') { go(1); }
  });

  render();
})();
