(function() {
  var Application, LinkFinder, app;
  LinkFinder = (function() {
    function LinkFinder() {}
    LinkFinder.prototype.visible = function(links) {
      var link, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = links.length; _i < _len; _i++) {
        link = links[_i];
        if ($(link).offset()['top'] > window.scrollY && $(link).offset()['top'] + $(link).height() < window.scrollY + $(window).height()) {
          _results.push(link);
        }
      }
      return _results;
    };
    LinkFinder.prototype.match = function(search_string) {
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
    return LinkFinder;
  })();
  Application = (function() {
    function Application() {
      this.activated = false;
      this.search_string = "";
      this.link_finder = new LinkFinder();
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
    Application.prototype.unfocus_links = function(links) {
      var link, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = links.length; _i < _len; _i++) {
        link = links[_i];
        _results.push($(link).removeClass("deadmouse-focused"));
      }
      return _results;
    };
    Application.prototype.focus_first_visible_link = function(links) {
      var visible_links;
      visible_links = this.link_finder.visible(links);
      return $(visible_links[0]).addClass("deadmouse-focused");
    };
    Application.prototype.follow_link = function(link) {
      $(link).addClass("deadmouse-clicked");
      return $(link).trigger("click");
    };
    Application.prototype.keypress = function(event) {
      var matches;
      if (document.activeElement === document.body) {
        this.activated = true;
        this.search_string += String.fromCharCode(event.keyCode);
        matches = this.link_finder.match(this.search_string);
        this.unhighlight_links($("a"));
        this.highlight_links(matches);
        this.unfocus_links($("a"));
        this.focus_first_visible_link(matches);
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
        this.activated = false;
        this.search_string = "";
        this.unhighlight_links($("a"));
        this.unfocus_links($("a"));
        return false;
      } else if (this.activated && event.keyCode === 9) {
        if (event.shiftKey) {
          console.log("shift+tab");
        } else {
          console.log("tab");
        }
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
