# Description:
#   Take notes and minutes 
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   torreto take notes
#   torreto clear all links
#
# Author
#   Samkit


class Note
  constructor: (@title,@date,@total) ->

module.exports = (robot) ->
  
  noteMode = false 
  noteTitle = null

  robot.respond /take notes about (.*)/i, (res) ->
    title = res.match[1]
    noteTitle = title
    date = new Date
    newdate = date.getFullYear() + '-'
        + pad(date.getMonth() + 1) + '-'
        + pad(date.getDate()) + 'T'
        + pad(date.getHours()) + ':'
        + pad(date.getMinutes()) + ':'
        + pad(date.getSeconds());
    note = new Note title,date,0
    robot.brain.set title,note
    res.send "Sure, go ahead type in, saving for #{newdate}"

  robot.hear /(.*)/i, (res) ->
    if noteMode
      currentNote = robot.brain.get  noteTitle
      currentNote.total = currentNote.total + 1
      robot.brain.set noteTitle,currentNote
      res.send "new line no #{currentNote.total}"
    else
      res.send "AM too lazzy"
      noteMode = true

  robot.hear /show notes about (.*)/i, (res) ->
    title = res.match[1]
    note = robot.brain.get title
    url = "https://api.hipchat.com/v2/room/Wergroot/history?date=#{note.date}&timezone=Asia/Tokyo&format=json&max-results=#{note.total}&auth_token=1coJkivHvITLQx343j75ziWKvjZX5VHG1Faus4hz"
    console.log(url);
    robot.http(url)
      .get() (err, resp, body) ->
        if err
          res.send "(areyoukiddqx1ingme) Got stuck here : #{err} "
          return
        try  
          data = JSON.parse(body)
        catch error
          res.send "That went over my head: #{err} (jackie)"
          return 
        console.log data
    res.send "#{url}"

  robot.respond /save this note/i, (res) ->
    currentNote = robot.brain.get  noteTitle
    currentNote.total = currentNote.total + 1
    date = new Date
    currentNote.date = date 
    robot.brain.set noteTitle,currentNote
    noteMode = false
    res.send "Okay sure done" 