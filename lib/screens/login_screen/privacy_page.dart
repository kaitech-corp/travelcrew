import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        leading: IconButton(
        icon: Icon(Icons.close),
          onPressed: (){
          Navigator.of(context).pop();
          },
        ),
    ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(width: 3, style: BorderStyle.solid, color: Colors.blueAccent)
          ),
          child: Column(
            children: <Widget>[
              Text('PRIVACY POLICY FOR TRAVEL CREW APPLICATION', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.blueAccent[300], fontWeight: FontWeight.bold,)),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),

              Text( 'This privacy policy governs your use of the software application Travel Crew for mobile devices that was created by Kai Technologies Corp. This application is a social, travel organizer for you and your friends and family. In this policy, “us”, “we”, or “our” means Kai Technologies Corp, operators of our mobile services, website and any software provided on or in connection with Kai Technologies Corp services.', textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text('We may, from time to time, review and update this privacy policy, including taking account of new or amended laws, new technology and/or changes to our operations. All personal information held by us will be governed by the most recently updated policy. By registering for Travel Crew you are accepting our services offered thereon, you are agreeing to be bound by this Privacy Policy, as updated from time to time.', textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text('What information do we obtain and how is it used?', style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text('User Provided Information', style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text('Travel Crew obtains the information you provide when you download and register the Application. The personal information we collect falls into the following categories: contact details and publishable content.',textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text('Contact details are collected as supplied by you from time to time. This may include, but is not limited to, your name, address, phone number, contact details, birth date, gender, credit card and account details (when applicable), and interests. We may also give you the option of providing a photo to be associated with your user ID. If your personal details change, it is your responsibility to update your account with those changes, so that we can keep our records complete, accurate and up to date. We do not personally store usable credit card information. You are not anonymous to us when you log into Travel Crew or post any content on our application.',textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text('Publishable content consists of text, comments, locations, images, videos, ratings or other submissions of content you would like us to publish on our Service. When you submit content to us for publication (including but not limited to comments, testimonials, ratings, images, flight information or forum posts) you assign us a transferrable, perpetual right to publish and/or commercially exploit said content without limitation. You also warrant in submitting such content that the content is owned or produced by yourself or you otherwise have permission to assign publication rights to us. Publication rights do not extend to fields specifically marked as private (e.g. your email address), except in cases of clear violations of our terms of use. Content submitted by you for publication may be disclosed to all visitors of our Service, and/or republished on other Services at our discretion.', textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("If you provide personal information either of your own or of any third party as part of publishable content, you warrant that you have permission to publish said information and indemnify us against any consequences resulting from the publication of said information. If you find your personal information published on our Service without your consent, please contact us immediately as outlined in section 10. We may also use the information you provided us to contact your from time to time to provide you with important information, required notices and marketing promotions.",textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("Automatically Collected Information",style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("In addition, this application may collect certain information automatically, including, but not limited to, the type of mobile device you use, your mobile devices unique device ID, the IP address of your mobile device, your mobile operating system, the type of mobile Internet browsers you use, and information about the way you use the Application.",textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("Do we collect precise real time location information of the device?",style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("This application does not collect precise information about the location of your mobile device.", textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("Do third parties see and/or have access to information obtained by us?", style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("Only aggregated, anonymized data is periodically transmitted to external services to help us improve the Application and our service. We will share your information with third parties only in the ways that are described in this privacy statement.", textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("We may disclose User Provided and Automatically Collected Information:",),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("as required by law, such as to comply with a subpoena, or similar legal process;"),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("when we believe in good faith that disclosure is necessary to protect our rights, protect your safety or the safety of others, investigate fraud, or respond to a government request;",),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("with our trusted services providers who work on our behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement.",),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("if Kai Technologies Corp. is involved in a merger, acquisition, or sale of all or a portion of its assets, you will be notified via email and/or a prominent notice on our Web site of any change in ownership or uses of this information, as well as any choices you may have regarding this information.",),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("What are my opt-out rights?", style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("You can stop all collection of information by the Application easily by uninstalling the Application. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network. You can also request to opt-out via email, at Kaitech2020@gmail.com.", textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("Data Retention Policy, Managing Your Information",style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("We will retain User Provided data for as long as you use the Application and for a reasonable time thereafter. We will retain Automatically Collected information for up to 24 months and thereafter may store it in aggregate. If you’d like us to delete User Provided Data that you have provided via the Application, please contact us at Kaitech2020@gmail.com and we will fulfill your request in a timely matter. Please note that some or all of the User Provided Data may be required in order for the Application to function properly.",textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("Children", style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("We do not use this application to knowingly solicit data from or market to children under the age of 13. If a parent or guardian becomes aware that his or her child has provided us with information without their consent, he or she should contact us at Kaitech2020@gmail.com. We will delete such information from our files within a reasonable time.",textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("Security",style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("We are concerned about safeguarding the confidentiality of your information. We provide physical, electronic, and procedural safeguards to protect information we process and maintain. For example, we limit access to this information to authorized employees and contractors who need to know that information in order to operate, develop or improve our Application. Please be aware that, although we endeavor provide reasonable security for information we process and maintain, no security system can prevent all potential security breaches.",textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("Changes",style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("This Privacy Policy may be updated from time to time for any reason. We will notify you of any changes to our Privacy Policy by posting the new Privacy Policy here and informing you via email or text message. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes. You can check the history of this policy by clicking here.",textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("Your Consent",style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("By using this application, you are consenting to our processing of your information as set forth in this Privacy Policy now and as amended by us. 'Processing,' means using cookies on a computer/hand held device or using or touching information in any way, including, but not limited to, collecting, storing, deleting, using, combining and disclosing information, all of which activities will take place in the United States. If you reside outside the United States your information will be transferred, processed and stored there under United States privacy standards.",textAlign: TextAlign.justify,),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("Contact us",style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
              ),
              Text("If you have any questions regarding privacy while using Travel Crew, or have questions about our practices, please contact us via email at Kaitech2020@gmail.com.", textAlign: TextAlign.justify,),

            ],
          ),
      ),
      )
    );
  }

}