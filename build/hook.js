(function() {
  var Application, Matcher, app, fuzzy;
  fuzzy = function(tabs, hint) {
    var i, j, matches, offset, results, tab, _i, _len, _ref, _ref2;
    results = [];
    if (hint === '') {
      return tabs;
    }
    for (_i = 0, _len = tabs.length; _i < _len; _i++) {
      tab = tabs[_i];
      matches = [];
      offset = tab.url.indexOf('/');
      for (i = 0, _ref = hint.length - 1; (0 <= _ref ? i <= _ref : i >= _ref); (0 <= _ref ? i += 1 : i -= 1)) {
        for (j = offset, _ref2 = tab.url.length - 1; (offset <= _ref2 ? j <= _ref2 : j >= _ref2); (offset <= _ref2 ? j += 1 : j -= 1)) {
          if (hint.charAt(i) === tab.url.charAt(j)) {
            offset = j;
            matches.push(offset);
            break;
          }
        }
        if (j === tab.url.length - 1 && j !== offset) {
          break;
        }
      }
      if (matches.length === hint.length) {
        results.push({
          tab: tab,
          matches: matches
        });
      }
    }
    return results;
  };
  Matcher = (function() {
    function Matcher() {}
    Matcher.prototype.match = function(search_string) {
      var link, needle, needles, regex, regex_pattern, _i, _len, _ref, _results;
      needles = search_string.split("");
      regex_pattern = ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = needles.length; _i < _len; _i++) {
          needle = needles[_i];
          _results.push(".*" + needle);
        }
        return _results;
      })()).concat(".*").join("");
      regex = new RegExp(regex_pattern, "i");
      _ref = $("a");
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        link = _ref[_i];
        if (regex.test(link.text)) {
          _results.push(link);
        }
      }
      return _results;
    };
    return Matcher;
  })();
  Application = (function() {
    function Application() {
      this.search_string = "";
      this.matcher = new Matcher();
    }
    Application.prototype.unhighlight_links = function(links) {
      var link, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = links.length; _i < _len; _i++) {
        link = links[_i];
        _results.push($(link).removeClass("deadmouse-highlighted"));
      }
      return _results;
    };
    Application.prototype.highlight_links = function(links) {
      var link, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = links.length; _i < _len; _i++) {
        link = links[_i];
        _results.push($(link).addClass("deadmouse-highlighted"));
      }
      return _results;
    };
    Application.prototype.follow_link = function(link) {
      $(link).addClass("deadmouse-clicked");
      return $(link).trigger("click");
    };
    Application.prototype.keypress = function(event) {
      var matches;
      if (document.activeElement === document.body) {
        this.search_string += String.fromCharCode(event.keyCode);
        matches = this.matcher.match(this.search_string);
        this.unhighlight_links($("a"));
        this.highlight_links(matches);
        if (matches.length === 1) {
          this.follow_link(matches[0]);
        }
        return false;
      } else {
        return true;
      }
    };
    Application.prototype.keydown = function(event) {
      if (event.keyCode === 27) {
        this.search_string = "";
        this.unhighlight_links($("a"));
        return false;
      }
    };
    return Application;
  })();
  app = new Application();
  $(window).on("keypress", function(e) {
    return app.keypress(event);
  });
  $(window).on("keydown", function(e) {
    return app.keydown(event);
  });
}).call(this);
