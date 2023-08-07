using System.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace Assets.Scripts
{
	public class Bifurcation : MonoBehaviour 
	{
		public void OnEnable ()
		{
			StartCoroutine(Run());
		}

		private IEnumerator Run()
		{
			yield return new WaitForSeconds(1f);

			Outline outline = GetComponent<Outline>();
			float time = 0f;
			while (time <= 1f)
			{
				float offset = Mathf.Lerp(0f, 30, time);
				outline.effectDistance = new Vector2(offset, offset);
				yield return null;
				time += Time.deltaTime*1.5f;
			}

			time = 0f;
			while (time <= 1f)
			{
				float offset = Mathf.Lerp(30, 0f, time);
				outline.effectDistance = new Vector2(offset, offset);
				yield return null;
				time += Time.deltaTime * 1.5f;
			}
		}
	}
}
