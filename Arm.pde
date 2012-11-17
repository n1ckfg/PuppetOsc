class Arm extends Limb{
  
    Arm(){
      super("lightning-h",12);
      init();
    }
    
    Arm(PImage[] _name){
      super(_name,12);
      init();
    }
    
    void init(){
      super.init();
      landscape = true;
    }    
    
}
