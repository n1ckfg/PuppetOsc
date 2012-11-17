class Leg extends Limb{
  
    Leg(){
      super("lightning-h",12);
      init();
    }
    
    Leg(PImage[] _name){
      super(_name,12);
      init();
    }
    
    void init(){
      super.init();
      landscape = true;
    }
    
}
