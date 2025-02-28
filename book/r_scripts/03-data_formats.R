library(xml2)


xml_test <- "<people>
<jason>
  <person type='fictional'>
    <first_name>
      <married>
        Jason
      </married>
    </first_name>
    <last_name>
        Bourne
    </last_name>
    <occupation>
      Spy
    </occupation>
  </person>
</jason>
<carol>
  <person type='real'>
    <first_name>
      <married>
        Carol
      </married>
    </first_name>
    <last_name>
        Kalp
    </last_name>
    <occupation>
      Scientist
    </occupation>
  </person>
</carol>
</people>
"

cat(xml_test)



html_test <- "<html>
  <head>
    <title>Div Align Attribbute</title>
  </head>
  <body>
    <div align='left'>
      First text
    </div>
    <div align='right'>
      Second text
    </div>
    <div align='center'>
      Third text
    </div>
    <div align='justify'>
      Fourth text
    </div>
  </body>
</html>
"


## <!DOCTYPE html>
## <html>
## <head>
## <title>Page Title</title>
## </head>
## <body>
## 
## <h1> <a href="www.google.com">This is a Heading </a> </h1>
## <br>
## <p>This is a paragraph.</p>
## 
## </body>
## </html>


xml_raw <- read_xml(xml_test)
xml_structure(xml_raw)


# xml_child returns only one child (specified in search)
# Here, jason is the first child
xml_child(xml_raw, search = 1)

# Here, carol is the second child
xml_child(xml_raw, search = 2)

# Use xml_children to extract **all** children
child_xml <- xml_children(xml_raw)

child_xml


# Extract the attribute type from all nodes
xml_attrs(child_xml, "type")


child_xml


# We go down one level of children
person_nodes <- xml_children(child_xml)

# <person> is now the main node, so we can extract attributes
person_nodes

# Both type attributes
xml_attrs(person_nodes, "type")


# Specific address of each person tag for the whole xml tree
# only using the `person_nodes`
xml_path(person_nodes)


# You can use results from xml_path like directories
xml_find_all(xml_raw, "/people/jason/person")


## <name>
## <person age="23" status="married" occupation="teacher"> John Doe </person>
## </name>

## <name>
## <person age="23" status="married" occupation="teacher"> John Doe </person>
## <person age="25" status="single" occupation="doctor"> Jane Doe </person>
## </name>


html_raw <- read_html(html_test)
html_structure(html_raw)



## <?xml version="1.0>
## <company>
##     <name> John Doe </name>
##     <email> johndoe@gmail.com </email>
## </address>

##  <!DOCTYPE html>
## <html>
## <body>
## 
## <h1>My First Heading</h1>
## <p>My first paragraph.</p>
## 
## </body>
## </html>

# div_nodes <- xml_child(html_raw, search = 2)
# xml_attrs(xml_children(div_nodes), "align")


# carol_node <- xml_child(xml_raw, search = 2)
# person_node <- xml_child(carol_node, search = 1)
# occupation <- xml_child(person_node, search = 3)
# xml_text(occupation)


# div_nodes <- xml_child(html_raw, search = 2)
# xml_text(xml_children(div_nodes), "align")


# custom_xml <- "<root>
# <child1 family='1'>
# <granchild1>
# </granchild1>
# <granchild2>
# </granchild2>
# </child1>
# 
# 
# <child2>
# <granchild1>
# </granchild1>
# <granchild2 family='1'>
# </granchild2>
# </child2>
# </root>"
# 
# custom_raw <- read_xml(custom_xml)
# 
# # First attribute
# xml_attrs(xml_find_all(custom_raw, "/root/child1"))
# 
# # Second attribute
# xml_attrs(xml_find_all(custom_raw, "/root/child2/granchild2"))


# xml_list <- as_list(xml_raw)
# xml_list$people$carol$person$last_name[[1]]

