void keyPressed(){
  if(key==' '){
  hideCursor = !hideCursor;
  if(hideCursor){
    noCursor();
  }else{
    cursor();
  }
  }
  if(key=='a'||key=='A') alphaMode = !alphaMode;
}
