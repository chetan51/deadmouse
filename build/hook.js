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
        if ($(link).is(":visible") && regex.test(link.text)) {
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
      this.matched_links = [];
      this.focused_link_index = 0;
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
    Application.prototype.update_link_focus = function() {
      var visible_links;
      visible_links = this.link_finder.visible(this.matched_links);
      return $(visible_links[this.focused_link_index]).addClass("deadmouse-focused");
    };
    Application.prototype.focus_first_visible_link = function() {
      this.focused_link_index = 0;
      return this.update_link_focus();
    };
    Application.prototype.focus_next_visible_link = function() {
      var visible_links;
      visible_links = this.link_finder.visible(this.matched_links);
      this.focused_link_index += 1;
      if (this.focused_link_index > visible_links.length - 1) {
        this.focused_link_index = 0;
      }
      return this.update_link_focus();
    };
    Application.prototype.focus_prev_visible_link = function() {
      var visible_links;
      visible_links = this.link_finder.visible(this.matched_links);
      this.focused_link_index -= 1;
      if (this.focused_link_index < 0) {
        this.focused_link_index = visible_links.length - 1;
      }
      return this.update_link_focus();
    };
    Application.prototype.follow_link = function(link) {
      $(link).addClass("deadmouse-clicked");
      return $(link).trigger("click");
    };
    Application.prototype.follow_focused_link = function() {
      var visible_links;
      visible_links = this.link_finder.visible(this.matched_links);
      return this.follow_link(visible_links[this.focused_link_index]);
    };
    Application.prototype.reset = function() {
      this.unhighlight_links($("a"));
      return this.unfocus_links($("a"));
    };
    Application.prototype.keypress = function(event) {
      if (document.activeElement === document.body) {
        this.activated = true;
        this.search_string += String.fromCharCode(event.keyCode);
        this.matched_links = this.link_finder.match(this.search_string);
        this.reset();
        this.highlight_links(this.matched_links);
        this.focus_first_visible_link();
        if (this.matched_links.length === 1) {
          this.follow_link(this.matched_links[0]);
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
        this.matched_links = [];
        this.focused_link_index = 0;
        this.reset();
        return false;
      } else if (this.activated && event.keyCode === 9) {
        this.unfocus_links($("a"));
        if (event.shiftKey) {
          this.focus_prev_visible_link();
        } else {
          this.focus_next_visible_link();
        }
        return false;
      } else if (this.activated && event.keyCode === 13) {
        this.reset();
        this.follow_focused_link();
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
