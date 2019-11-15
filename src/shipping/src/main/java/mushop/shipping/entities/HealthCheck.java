package mushop.shipping.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.util.Calendar;
import java.util.Date;

import org.json.JSONObject;

/*
 * 
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class HealthCheck {
   private String service;
   private String status;

   @JsonFormat(pattern="yyyy-MM-dd'T'HH:mm:ss.SSSXXX")
   private Date date = Calendar.getInstance().getTime();

   /*
    * 
    */
   public HealthCheck() {

   }

   /*
    * 
    */
   public HealthCheck(String service, String status, Date date) {
      this.service = service;
      this.status = status;
      this.date = date;
  }

   /*
    * 
    */
   @Override
   public String toString() {
      JSONObject hc = new JSONObject();
      hc.put("service", service);
      hc.put("status", status);
      hc.put("date", date);
      return hc.toString();
   }

   /*
    * 
    */
   public String getService() {
      return service;
   }

   /*
    * 
    */
   public void setService(String service) {
      this.service = service;
   }

   /*
    * 
    */
   public String getStatus() {
      return status;
   }

   /*
    * 
    */
   public void setStatus(String status) {
      this.status = status;
   }

   /*
    * 
    */
   public Date getDate() {
      return date;
   }

   /*
    * 
    */
   public void setDate(Date date) {
      this.date = date;
   }
}
