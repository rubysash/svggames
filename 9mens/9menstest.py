import svgwrite
import json

'''
This python script is a demo of using python to 
create a simple board game.    Similar code to this
is used for converting SVG to GCode for my CNC router
I didn't have the SVG I wanted, so this was written 
in Perl.  Then I realized nobody except me likes Perl!
So I wrote it in Python.   Sharing Code and Game.
The game is very old, and has been found carved in stones
in Egyption pyramids. 

topics learned:

python module "svgwrite"
python pip installing modules
python comments
python multiline comments
python escaping characters
python dictionary data structure
python dictionary of lists structure
python for loops
python splitting strings
python converting string to float
python functions
python passing variables
python basic math operator

Tutorial Found: https://www.w3schools.com/python/default.asp

SVG Basics
SVG File Creation
SVG Text
SVG Circles
SVG Squares
SVG Lines/Paths
SVG Styles

JSON Basics
JSON loading json file
JSON writing json file
JSON indenting json file

9 Men's Morris Rules
'''

# adjust as needed, it is a "S"VG after all
# 82 with min margins my Brother HL-L5200DW fit full page
# 67 with zero margins is designed for the wooden boards and CNC
scale   = 82 # 82 for printing, 67 for CNC
dotsize = .15 # between .12 and .2 probably
stroke  = 5  # should probably be an odd number so it's centered, probably 5 or 7

# didn't work, should be scale * 8 (paper) or 9.5 (CNC)
#dbwide = 570 
#dbhigh = 570 

# where will this be written?  
# And create the dwg object
#dwg = svgwrite.Drawing('9menspython.svg', profile='tiny')
'''fixme:  
	couldn't get size/viewBox to work properly
	this would be useful for printing easier without 
	messing with print dialogues, or to standardize 
	CNC conversions.  These options work but do not
	actually limit the size/viewBox.

	particularly, I couldn't use a variable in the setttings
	Probably need to int/float whatever it.

	Busy today, resume another day.
'''
dwg = svgwrite.Drawing(
	'9menspython.svg',
	#size=(637,637),
	#viewBox=(0,0,637,637)
	)


# open json file
with open("9men.json", "r") as read_file:
    # put it into a dictionary called "data"
    data = json.load(read_file)

'''
makedots:  
takes xy coords, radius and fill color
makes a dot at that location
'''
def makedots(x,y,r,color):
	x = x * scale
	y = y * scale
	r = dotsize * scale
	dwg.add(
		dwg.circle(
			center=(x,y),
			r=r,
			stroke=svgwrite.rgb(10, 10, 10),
			fill=color
		)
	)

'''
makelines:  
takes xy start and stopcoords
makes a line from xy1 to xy2
'''
def makelines(x1,y1,x2,y2):
	x1 = x1 * scale
	y1 = y1 * scale
	x2 = x2 * scale
	y2 = y2 * scale
	dwg.add(
		dwg.line(
			start=(x1,y1),
			end=(x2,y2),
			stroke=svgwrite.rgb(10, 10, 20),
			stroke_width=stroke
		)
	)

'''
makesquares:  
takes xy near and far corners
draws rectangle using those points
'''
def makesquares(x1,y1,x2,y2):
	# draw a nofill box
	x1 = x1 * scale
	y1 = y1 * scale
	x2 = x2 * scale
	y2 = y2 * scale
	dwg.add(
		dwg.rect(
			(x1, y1), (x2, y2),
	    	stroke=svgwrite.rgb(10, 10, 20),
	    	stroke_width=stroke,
	    	fill='none'
	    )
	)
'''
makeslabels:
x,y start, font size in '12px' format, and then your text
puts text on the screen. 
'''
def makelabels(x,y,size,text):
	x = x * scale
	y = y * scale
	dwg.add(
		dwg.text(
			text,
			insert=(x,y),
			stroke='none',
			fill=svgwrite.rgb(15,15,15),
			font_size=size,
			font_weight="bold",
			style="font-family:Arial"
		)
	)

# functions are defined above, so... 
# do whatever the json says now

# fixme:  put the rules into the json, like the title
# MAKE LABELS (RULES):
makelabels(3.65,2.90,'18px',data['title'])

makelabels(2.74,3.15,'11px',"Each player starts with 9 stones. (Black vs White)")

makelabels(2.74,3.50,'11px',"Stage 1 (Placement): Take turns placing stones.")
makelabels(2.74,3.75,'11px',"Get 3 in a row, on a connected line, remove 1 of your")
makelabels(2.74,4.00,'11px',"opponent's pieces (break strings as last choice.)")

makelabels(2.74,4.40,'11px',"Stage 2 (Movement): Take turns moving your pieces.")
makelabels(2.74,4.60,'11px',"1 at a time, attempting to get 3 in a row, again.")
makelabels(2.74,4.80,'11px',"If you get 3 in a row, take 1 of your opponent's")
makelabels(2.74,5.00,'11px',"pices (break strings as a last choice)")

makelabels(2.74,5.40,'11px',"Stage 3 (Underdog): When anyone gets down to only")
makelabels(2.74,5.60,'11px',"3 pieces, they are not bound by lines and can jump")
makelabels(2.74,5.80,'11px',"to any unoccupied spot on board.")

makelabels(2.74,6.20,'11px',"To Win: Capture opponent down to 2 pieces")

# DOTS:
# loop over the len number of items in this list
# assign the numbers to "i", 0,1,2,3 etc
for i in range(len(data['dots'])):
	# create a string from this data
	chunk = data['dots'][i]
	# spolit string into another list, on every comma
	xy = chunk.split(',')

	# make the data back to a float from string
	xx = float(xy[0])
	yy = float(xy[1])

	# call the function
	makedots(xx,yy,10,'black')

# LINES:
for i in range(len(data['lines'])):
	chunk = data['lines'][i]
	xy = chunk.split(',')
	x1 = float(xy[0])
	y1 = float(xy[1])
	x2 = float(xy[2])
	y2 = float(xy[3])
	makelines(x1,y1,x2,y2)

# SQUARES:
for i in range(len(data['squares'])):
	chunk = data['squares'][i]
	xy = chunk.split(',')
	x1 = float(xy[0])
	y1 = float(xy[1])
	x2 = float(xy[2])
	y2 = float(xy[3])
	makesquares(x1,y1,x2,y2)

#we did read it originall, but I want to see
# how python sees it.
with open('9mendict.json', 'w') as outfile:  
    json.dump(data, outfile,indent=4)

# output our svg image as raw xml
#print(dwg.tostring())

# write svg file to disk
dwg.save()


