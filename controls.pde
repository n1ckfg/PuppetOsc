void keyPressed(){
  hideCursor = !hideCursor;
  if(hideCursor){
    noCursor();
  }else{
    cursor();
  }
}
