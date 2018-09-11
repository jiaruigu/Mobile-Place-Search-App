<?php
  function query($url, $api_key){
    try {
      $curl = curl_init();
      curl_setopt_array($curl, array(
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,  // Capture response.
        CURLOPT_ENCODING => "",  // Accept gzip/deflate/whatever.
        CURLOPT_MAXREDIRS => 10,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
        CURLOPT_CUSTOMREQUEST => "GET",
        CURLOPT_HTTPHEADER => array(
            "authorization: Bearer ". $api_key,
            "cache-control: no-cache",
        ),
      ));
      $response = curl_exec($curl);
      return $response;
    }
    catch(Exception $e) {
      trigger_error(sprintf(
          'Curl failed with error #%d: %s',
          $e->getCode(), $e->getMessage()),
          E_USER_ERROR);
    }
  }
  if (isset($_REQUEST["QueryType"])){
    $QueryType = $_REQUEST["QueryType"];
    if($QueryType == "PlaceNearBy"){
      $Keyword = $_REQUEST["Keyword"];
      $Category = $_REQUEST["Category"];
      $Distance = $_REQUEST["Distance"]*1609.344;
      $Location = $_REQUEST["Location"];
      $Flag_LatLon = $_REQUEST["Flag_LatLon"];
      if($Keyword!="" && $Category!="" && $Distance!="" && $Location!="" && $Flag_LatLon!=""){
        if($Flag_LatLon == "false"){
          $Location = str_replace(' ', '+', $Location);
          $jsonurl = "https://maps.googleapis.com/maps/api/geocode/json?address=$Location&key=YourGoogleApiKey";
          $json = file_get_contents($jsonurl);
          $jsonObj = json_decode($json,true);
          $Location = $jsonObj["results"][0]["geometry"]["location"]["lat"].",".$jsonObj["results"][0]["geometry"]["location"]["lng"];
        }
        if($Category == "default"){
          $Keyword = str_replace(' ', '+', $Keyword);
          $jsonurl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$Location&radius=$Distance&keyword=$Keyword&key=YourGoogleApiKey";
        }
        else{
          $Keyword = str_replace(' ', '+', $Keyword);
          $jsonurl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$Location&radius=$Distance&type=$Category&keyword=$Keyword&key=YourGoogleApiKey";
        }
        $json = file_get_contents($jsonurl);
        $jsonObjs = array(json_decode($json,true));
        $idx=0;
        while(isset($jsonObjs[$idx]["next_page_token"])){
          $PageToken=$jsonObjs[$idx]["next_page_token"];
          $jsonurl="https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=$PageToken&key=YourGoogleApiKey";
          $status="INVALID_REQUEST";
          while($status=="INVALID_REQUEST"){
            $json = file_get_contents($jsonurl);
            $jsonObj = json_decode($json,true);
            $status = $jsonObj["status"];
          }
          array_push($jsonObjs,$jsonObj);
          $idx+=1;
        }
        echo json_encode($jsonObjs);
      }
    }
    else if($QueryType == "PlaceDetail"){
      $PlaceId = $_REQUEST["PlaceId"];
      if($PlaceId!=""){
        $jsonurl = "https://maps.googleapis.com/maps/api/place/details/json?placeid=$PlaceId&key=YourGoogleApiKey";
        $json = file_get_contents($jsonurl);
        $jsonObj = json_decode($json,true);
        for($i=0;$i<sizeof($jsonObj["result"]["photos"]);$i++){
          $PhotoReference = $jsonObj["result"]["photos"][$i]["photo_reference"];
          $jsonObj["result"]["photos"][$i]["photo_reference"]="https://maps.googleapis.com/maps/api/place/photo?maxwidth=250&photoreference=$PhotoReference&key=YourGoogleApiKey";
        }
        echo json_encode($jsonObj);
      }
    }
    else if($QueryType == "YelpReview"){
      $name = $_REQUEST["name"];
      $city = $_REQUEST["city"];
      $state = $_REQUEST["state"];
      $country = $_REQUEST["country"];
      $address1 = $_REQUEST["address1"];
      $url_params=array();
      $url_params["name"]=$name;
      $url_params["city"]=$city;
      $url_params["state"]=$state;
      $url_params["country"]=$country;
      $url_params["address1"]=$address1;
      $api_key = "Your YelpApiKey";
      $match_url = "https://api.yelp.com/v3/businesses/matches/best?".http_build_query($url_params);
      $json_obj = json_decode(query($match_url, $api_key));
      $business_id = $json_obj->businesses[0]->id;
      $reviews_url = "https://api.yelp.com/v3/businesses/$business_id/reviews";
      echo query($reviews_url, $api_key);
    }
  }
?>