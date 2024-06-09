using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class OutputInfo : MonoBehaviour
{
    public Transform canvasTransform;
    public Camera mainCamera;
    public AudioProcessor audio;
    public TextMeshProUGUI infoText;
    int clickCount = 0;
   
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        

        infoText.text = mainCamera.transform.position.ToString() + "\n" + mainCamera.transform.rotation.eulerAngles.ToString() + "\n" + audio.AudioVolume.ToString() + "\n" + "ClockCount:" + clickCount.ToString();

        //Texture2D human_tex = GameManager.Instance.OcclusionManager.environmentDepthTexture;
        //if (human_tex == null)
        //    infoText.text += "\n" + "Null";
        //else
        //    infoText.text += "\n" + "TexelSize:" + human_tex.texelSize.ToString();

        canvasTransform.position = mainCamera.transform.TransformPoint(Vector3.forward * 1);
    }

    public void OnClickButton()
    {
        clickCount++;
    }
}
