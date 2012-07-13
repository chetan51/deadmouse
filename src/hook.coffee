class LinkFinder
  is_visible: (link) ->
    return $(link).is(":visible") and $(link).offset()['top'] > window.scrollY and $(link).offset()['top'] + $(link).height() < window.scrollY + $(window).height()
  
  match: (search_string) ->
    scores = ([link, link.text.score(search_string)] for link in $("a")).sort((a, b) -> b[1] - a[1])
    links = (tuple[0] for tuple in scores)
    return (link for link in links when this.is_visible(link))

class DomUtils
  constructor: ->
    if (navigator.userAgent.indexOf("Mac") != -1)
      @platform = "Mac"
    else if (navigator.userAgent.indexOf("Linux") != -1)
      @platform = "Linux"
    else
      @platform = "Windows"

  simulateClick: (element, modifiers) ->
    modifiers ||= {}

    eventSequence = ["mouseover", "mousedown", "mouseup", "click"]
    for event in eventSequence
      mouseEvent = document.createEvent("MouseEvents")
      mouseEvent.initMouseEvent(event, true, true, window, 1, 0, 0, 0, 0, modifiers.ctrlKey, false, false, modifiers.metaKey, 0, null)
      element.dispatchEvent(mouseEvent)

class Application
  constructor: ->
    this.reset()
    this.link_finder = new LinkFinder()
    this.dom_utils   = new DomUtils()

  reset: ->
    this.activated = false
    this.search_string = ""
    this.matched_links = []
    this.focused_link_index = 0
    
  unfocus_links: (links) ->
    
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
    
  follow_link: (link, new_window) ->
    if new_window
      modifiers =
        metaKey: this.dom_utils.platform == "Mac"
        ctrlKey: this.dom_utils.platform != "Mac"
    else
      $(link).addClass("deadmouse-clicked")
    this.dom_utils.simulateClick(link, modifiers)

  follow_focused_link: (new_window) ->
    this.follow_link(this.matched_links[this.focused_link_index], new_window)
    
  clear: ->
    $(link).removeClass("deadmouse-focused") for link in $("a")
    $(link).removeClass("deadmouse-clicked") for link in $("a")

  keypress: (event) ->
    if not this.activated and event.keyCode == 32 # Space pressed first
      return true
    else if document.activeElement == document.body # no input is focused
      this.activated = true
      this.search_string += String.fromCharCode(event.keyCode)
      this.matched_links = this.link_finder.match(this.search_string)
      
      this.clear()
      this.focus_first_link()
      
      return false
    else
      return true
  
  keydown: (event) ->
    if event.keyCode == 27 or event.keyCode == 8 # Esc or Backspace pressed
      this.activated = false
      this.search_string = ""
      this.matched_links = []
      this.focused_link_index = 0
      
      this.clear()
      this.reset()
      
      return false
    else if this.activated and event.keyCode == 9 # Tab pressed
      this.clear()
      
      if event.shiftKey
        this.focus_prev_link()
      else
        this.focus_next_link()
       
      return false
    else if this.activated and event.keyCode == 13 # Enter pressed
      this.clear()

      if event.shiftKey
        this.follow_focused_link(true)
      else
        this.follow_focused_link(false)

      this.reset()
      return false

app = new Application()

$(window).on "keypress", (e) ->
  return app.keypress(event)

$(window).on "keydown", (e) ->
  return app.keydown(event)
