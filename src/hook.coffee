# fuzzy algorithm
# TODO : weight differently occurences depending if they 
#        are in domain, path or even GET parameters
fuzzy = (tabs, hint)-> 
  results = [] 
  return tabs if hint == ''
  
  for tab in tabs 
    matches = []
    
    # Set offset to the first letter of the domain, ignoring procotol 
    offset = tab.url.indexOf '/'

    for i in [0..hint.length-1]
      for j in [offset..tab.url.length-1] 
        if hint.charAt(i) == tab.url.charAt(j)
          offset = j
          matches.push offset
          break
      break if j == tab.url.length - 1 and j != offset
    results.push {tab:tab, matches:matches} if matches.length == hint.length

  results 

class Matcher
  match: (search_string) ->
    needles = search_string.split("")
    regex_pattern = (".*" + needle for needle in needles).concat(".*").join("")
    regex = new RegExp(regex_pattern, "i")
    return (link for link in $("a") when regex.test(link.text))

class Application
  constructor: ->
    this.search_string = ""
    this.matcher = new Matcher()
    
  unhighlight_links: (links) ->
    $(link).removeClass("deadmouse-highlighted") for link in links
    
  highlight_links: (links) ->
    $(link).addClass("deadmouse-highlighted") for link in links
   
  follow_link: (link) ->
    $(link).addClass("deadmouse-clicked")
    $(link).trigger("click")

  keypress: (event) ->
    this.search_string += String.fromCharCode(event.keyCode)
    matches = this.matcher.match(this.search_string)
    this.unhighlight_links($("a"))
    this.highlight_links(matches)
    if matches.length == 1
      this.follow_link(matches[0])
    return false
  
  keydown: (event) ->
    if event.keyCode == 27 # Esc pressed
      this.search_string = ""
      this.unhighlight_links $("a")
      return false

app = new Application()

$(document).on "keypress", (e) ->
  return app.keypress(event)

$(document).on "keydown", (e) ->
  return app.keydown(event)
