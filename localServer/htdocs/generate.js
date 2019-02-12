/**
 * With this file the html gets filled.
 */

 /**
  * Generates all the HTML.
  */
 function generateAll() {
    setItems()
 }

/**
 * Sets all the items into the table.
 */
function setItems() {
    let table = document.getElementById('items-table')
    let row = table.insertRow(0)
    let cell1 = row.insertCell(0)
    cell1.innerHTML = '<image src="img/hookshot.png" />'
}