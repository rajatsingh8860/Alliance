import 'package:flutter/material.dart';


class SliderModel{

  String imageAssetPath;
  String title;
  String desc;

  SliderModel({this.imageAssetPath,this.title,this.desc});

  void setImageAssetPath(String getImageAssetPath){
    imageAssetPath = getImageAssetPath;
  }

  void setTitle(String getTitle){
    title = getTitle;
  }

  void setDesc(String getDesc){
    desc = getDesc;
  }

  String getImageAssetPath(){
    return imageAssetPath;
  }

  String getTitle(){
    return title;
  }

  String getDesc(){
    return desc;
  }

}


List<SliderModel> getSlides(){

  List<SliderModel> slides = new List<SliderModel>();
  SliderModel sliderModel = new SliderModel();
  //1
  sliderModel.setDesc("Find People like You");
  sliderModel.setTitle("Alliance");
  sliderModel.setImageAssetPath("assets/taxi.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //2
  sliderModel.setDesc("Host and Attend\n"
      "Meetups\n"
      "Hassle Free");
  sliderModel.setTitle("");
  sliderModel.setImageAssetPath("assets/teamwork.png");
  slides.add(sliderModel);

  sliderModel = new SliderModel();

  //3
  sliderModel.setDesc("");
  sliderModel.setTitle("");
  sliderModel.setImageAssetPath("assets/signin.png");
  slides.add(sliderModel);
  return slides;
}
