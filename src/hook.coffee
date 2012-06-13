class LinkFinder
  is_visible: (link) ->
    return $(link).is(":visible") and $(link).offset()['top'] > window.scrollY and $(link).offset()['top'] + $(link).height() < window.scrollY + $(window).height()
  
  match: (search_string) ->
    needles = search_string.split("")
    regex_pattern = (".*" + needle for needle in needles).concat(".*").join("")
    regex = new RegExp(regex_pattern, "i")
    return (link for link in $("a") when this.is_visible(link) and regex.test(link.text))

class Application
  constructor: ->
    this.activated = false
    this.search_string = ""
    this.matched_links = []
    this.focused_link_index = 0
    this.link_finder = new LinkFinder()
    
  unhighlight_links: (links) ->
    $(link).removeClass("deadmouse-highlighted").removeClass("deadmouse-clicked") for link in links
    
  highlight_links: (links) ->
    $(link).addClass("deadmouse-highlighted") for link in links
    
  unfocus_links: (links) ->
    $(link).removeClass("deadmouse-focused") for link in links
    
  update_link_focus: ->
    $(this.matched_links[this.focused_link_index]).addClass("deadmouse-focused")
    
  focus_first_link: ->
    this.focused_link_index = 0
    this.update_link_focus()
    
  focus_next_link: ->
    this.focused_link_index += 1
    if this.focused_link_index > this.matched_links.length - 1
      this.focused_link_index = 0
    this.update_link_focus()
   
  focus_prev_link: ->
    this.focused_link_index -= 1
    if this.focused_link_index < 0
      this.focused_link_index = this.matched_links.length - 1
    this.update_link_focus()
    
  follow_link: (link) ->
    $(link).addClass("deadmouse-clicked")
    $(link).trigger("click")

  follow_focused_link: ->
    this.follow_link(this.matched_links[this.focused_link_index])
    
  reset: ->
    this.unhighlight_links($("a"))
    this.unfocus_links($("a"))

  keypress: (event) ->
    if document.activeElement == document.body # no input is focused
      this.activated = true
      this.search_string += String.fromCharCode(event.keyCode)
      this.matched_links = this.link_finder.match(this.search_string)
      
      this.reset()
      this.highlight_links(this.matched_links)
      this.focus_first_link()
      
      if this.matched_links.length == 1
        this.follow_link(this.matched_links[0])
      return false
    else
      return true
  
  keydown: (event) ->
    if event.keyCode == 27 # Esc pressed
      this.activated = false
      this.search_string = ""
      this.matched_links = []
      this.focused_link_index = 0
      
      this.reset()
      
      return false
    else if this.activated and event.keyCode == 9 # Tab pressed
      this.unfocus_links($("a"))
      
      if event.shiftKey
        this.focus_prev_link()
      else
        this.focus_next_link()
       
      return false
    else if this.activated and event.keyCode == 13 # Enter pressed
      this.reset()
      this.follow_focused_link()
      return false

app = new Application()

$(window).on "keypress", (e) ->
  return app.keypress(event)

$(window).on "keydown", (e) ->
  return app.keydown(event)
